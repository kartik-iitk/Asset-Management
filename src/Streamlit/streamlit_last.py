import streamlit as st
import mysql.connector
import pandas as pd
from datetime import datetime


# ───────────────────────── DB CONNECTION ──────────────────────────
def get_connection():
    return mysql.connector.connect(
        host="localhost", user="kartik", password="kartik", database="AssetManagement"
    )


# ───────────────────────── AUTHENTICATION ─────────────────────────
def authenticate(username, password):
    conn = get_connection()
    cur = conn.cursor(dictionary=True, buffered=True)
    cur.execute(
        """
        SELECT u.UserId, r.RoleName
          FROM Users u
          JOIN UserRole ur ON u.UserId = ur.UserId
          JOIN Roles    r  ON ur.RoleId = r.RoleId
         WHERE u.UserName     = %s
           AND u.UserPassword = %s
           AND u.IsActive     = 1
         LIMIT 1
        """,
        (username, password),
    )
    row = cur.fetchone()
    cur.close()
    conn.close()
    return row


# ───────────────────────── LOGIN PAGE ────────────────────────────
def login_screen():
    st.title("Asset Management System")
    user = st.text_input("Username")
    pwd = st.text_input("Password", type="password")

    if st.button("Login"):
        info = authenticate(user, pwd)
        if info:
            st.session_state.user_role = info["RoleName"]
            st.session_state.user_id = info["UserId"]
            st.success(f"Logged in as **{info['RoleName']}**")
        else:
            st.error("Invalid credentials")


# ───────────────────────── NAVIGATION ────────────────────────────
def navigation():
    page = st.sidebar.radio(
        "Navigate",
        [
            "Activities",
            "Inventory",
            "Requests",
            "Request Approvals",
            "Purchase Orders",
            "PO Approvals",
            "Reports",
            "SQL Console",
        ],
    )

    {
        "Activities": activities,
        "Inventory": inventory,
        "Requests": request_management,
        "Request Approvals": request_approvals,  # ← renamed here
        "Purchase Orders": purchase_orders,
        "PO Approvals": po_approvals,
        "Reports": reports,
        "SQL Console": sql_console,
    }[
        page
    ]()  # call the selected page-function


# ───────────────────────── ACTIVITIES PAGE ───────────────────────
def activities():
    st.header("Activities by Lab")
    conn = get_connection()
    cur = conn.cursor()

    # ─────── Choose lab ─────────────────────────────────────────
    cur.execute("SELECT LabId, LabName FROM Lab WHERE IsActive=1")
    lab_map = {name: lid for lid, name in cur.fetchall()}
    lab_sel = st.selectbox("Select Lab", [""] + list(lab_map.keys()))
    if not lab_sel:
        st.info("Choose a lab first.")
        cur.close()
        conn.close()
        return
    lab_id = lab_map[lab_sel]

    # ─────── Show existing activities ───────────────────────────
    cur.execute(
        """
        SELECT ActivityId, ActivityType, ActivityDescription,
               FundsAvailable, StartDate, EndDate,
               NOT IsClosed AS Active
          FROM LabActivity
         WHERE LabId = %s
    """,
        (lab_id,),
    )
    acts = cur.fetchall()
    cur.close()
    conn.close()

    if acts:
        st.dataframe(
            pd.DataFrame(
                acts,
                columns=[
                    "ID",
                    "Type",
                    "Description",
                    "Funds Available",
                    "Start Date",
                    "End Date",
                    "Active",
                ],
            ),
            use_container_width=True,
        )
    else:
        st.write("No activities found for this lab.")

    # ─────── Create New Activity ────────────────────────────────
    st.markdown("---")
    st.subheader("Create New Activity")
    with st.form("new_act"):
        c1, c2 = st.columns(2)
        with c1:
            a_type = st.text_input("Activity Type")
            a_desc = st.text_input("Activity Description")
            funds = st.number_input("Initial Funds", min_value=0.0, step=100.0)
        with c2:
            sd = st.date_input("Start Date", datetime.today())
            ed = st.date_input("End Date", datetime.today())
        submitted = st.form_submit_button("Create Activity")

    if submitted:
        conn2 = get_connection()
        cur2 = conn2.cursor()
        try:
            # Only call sp_create_activity (7 args) — it already handles fund movement
            cur2.callproc(
                "sp_create_activity",
                [
                    lab_id,
                    st.session_state.user_id,
                    a_type,
                    a_desc,
                    funds,
                    datetime.combine(sd, datetime.min.time()),
                    datetime.combine(ed, datetime.min.time()),
                ],
            )
            conn2.commit()
            st.success("Activity created (funds allocated)!")
        except Exception as e:
            conn2.rollback()
            st.error(f"Failed: {e}")
        finally:
            cur2.close()
            conn2.close()


# ───────────────────────── INVENTORY PAGE  ───────────────────────
def inventory():
    st.header("Inventory")
    tabs = st.tabs(["Items", "Assets", "Transactions"])
    spec = [
        (
            "Items",
            "SELECT ItemId, Category, Make, Model FROM Item WHERE IsActive=1",
            ["Item ID", "Category", "Make", "Model"],
        ),
        (
            "Assets",
            "SELECT AssetId, SerialNo, QuantityAvailable, StorageLocation FROM Asset",
            ["Asset ID", "Serial No", "Quantity", "Location"],
        ),
        (
            "Transactions",
            "SELECT TransactionId, TransactionAction, Quantity, DateCreated "
            "FROM AssetTransactionLog",
            ["Txn ID", "Action", "Qty", "Date"],
        ),
    ]
    for i, (ttl, qry, cols) in enumerate(spec):
        with tabs[i]:
            con = get_connection()
            cur = con.cursor()
            cur.execute(qry)
            st.dataframe(
                pd.DataFrame(cur.fetchall(), columns=cols), use_container_width=True
            )
            cur.close()
            con.close()


# ───────────────────────── REQUESTS PAGE ──────────────────────────
def request_management() -> None:
    """Create item-requests and review previous requests for a lab."""
    st.header("Raise / View Requests")

    # one-shot success banner
    if msg := st.session_state.pop("req_success", None):
        st.success(msg)

    if "cart" not in st.session_state:
        st.session_state.cart = []  # each item: {ItemId, label, qty}

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # ① choose lab ------------------------------------------------------
        cur.execute("SELECT LabId, LabName FROM Lab ORDER BY LabName")
        lab_map = {r["LabName"]: r["LabId"] for r in cur.fetchall()}
        lab_sel = st.selectbox("Lab", lab_map.keys())
        lab_id = lab_map[lab_sel]

        # ② existing requests ----------------------------------------------
        st.subheader("Existing requests for this lab")
        cur.execute(
            """
            SELECT r.RequestId            AS `Req ID`,
                   la.ActivityDescription AS Activity,
                   r.ItemId               AS Item,
                   r.QuantityRequested    AS Qty,
                   r.RequestDate          AS `Date`,
                   r.RequestStatus        AS Status
              FROM Request       r
              JOIN LabActivity   la ON la.ActivityId = r.ActivityId
             WHERE la.LabId = %s
             ORDER BY r.RequestDate DESC
            """,
            (lab_id,),
        )
        rows = cur.fetchall()
        if rows:
            st.dataframe(pd.DataFrame(rows), use_container_width=True)
        else:
            st.info("No request records for this lab yet.")

        # ③ create a new request -------------------------------------------
        st.markdown("---")
        st.subheader("Create new request")

        # ③-a  select activity ---------------------------------------------
        cur.execute(
            """
            SELECT ActivityId, ActivityDescription
              FROM LabActivity
             WHERE LabId = %s
             ORDER BY ActivityDescription
            """,
            (lab_id,),
        )
        acts = {
            f"{r['ActivityDescription']} (ID {r['ActivityId']})": r["ActivityId"]
            for r in cur.fetchall()
        }
        act_sel = st.selectbox("Activity", acts.keys())
        act_id = acts[act_sel]

        # ③-b  show current stock (info-only) ------------------------------
        cur.execute(
            """
            SELECT i.ItemId,
                   COALESCE(SUM(a.QuantityAvailable),0) AS Stock
              FROM Item  i
              LEFT JOIN Asset a
                     ON a.ItemId = i.ItemId AND a.LabId = %s
             GROUP BY i.ItemId
             ORDER BY i.ItemId
            """,
            (lab_id,),
        )
        stock_df = pd.DataFrame(cur.fetchall())
        st.markdown("##### Assets currently in this lab")
        if not stock_df.empty:
            st.dataframe(stock_df, use_container_width=True)
        else:
            st.info("This lab owns no assets yet.")

        # ③-c  item picker (ItemId only) -----------------------------------
        cur.execute("SELECT ItemId FROM Item WHERE IsActive = 1 ORDER BY ItemId")
        item_ids = [str(r["ItemId"]) for r in cur.fetchall()]  # strings for UI

        with st.form("add_item", clear_on_submit=True):
            col1, col2 = st.columns([3, 1])
            with col1:
                item_lbl = st.selectbox("Item ID to request", item_ids)
            with col2:
                qty = st.number_input("Qty", min_value=1, step=1, value=1)
            submitted = st.form_submit_button("Add to cart")

        if submitted:
            itm_id = int(item_lbl)  # back to int for DB
            # merge duplicates if same ItemId already in cart
            for line in st.session_state.cart:
                if line["ItemId"] == itm_id:
                    line["qty"] += qty
                    break
            else:
                st.session_state.cart.append(
                    {"ItemId": itm_id, "label": item_lbl, "qty": qty}
                )
            st.success("Added to cart!")

        # ③-d  cart display / remove ---------------------------------------
        if st.session_state.cart:
            st.markdown("#### Items in this request")
            for idx, line in enumerate(st.session_state.cart):
                c1, c2 = st.columns([6, 1])
                with c1:
                    st.write(f"**Item {line['label']}** — Qty {line['qty']}")
                with c2:
                    if st.button("Remove", key=f"rm{idx}"):
                        st.session_state.cart.pop(idx)
                        st.rerun()  # safe – does not print DG

        # ③-e  submit: one proc-call per cart line -------------------------
        if st.session_state.cart and st.button("Submit request"):
            try:
                cur2 = conn.cursor()
                for line in st.session_state.cart:
                    cur2.callproc(
                        "sp_raise_request",
                        [act_id, st.session_state.user_id, line["ItemId"], line["qty"]],
                    )
                conn.commit()
                st.session_state.cart.clear()
                st.session_state.req_success = "Request submitted!"
                st.rerun()
            except Exception as e:
                conn.rollback()
                st.error(f"Failed to submit request: {e}")

    finally:
        cur.close()
        conn.close()


# ───────────────────────── REPORTS PAGE  ────────────────────────
# def reports():
#     import pandas as pd
#     st.header("Lab-level reports")

#     conn = get_connection(); cur = conn.cursor(dictionary=True)
#     try:
#         # lab picker
#         cur.execute("SELECT LabId, LabName FROM Lab ORDER BY LabName")
#         lab_map = {r["LabName"]: r["LabId"] for r in cur.fetchall()}
#         if not lab_map: st.warning("No labs found."); return
#         lab_sel = st.selectbox("Lab", lab_map.keys()); lab_id = lab_map[lab_sel]

#         # activities + funds
#         cur.execute("""
#             SELECT ActivityId AS ID, ActivityDescription AS Activity,
#                    FundsAvailable AS `Funds Available`
#               FROM LabActivity
#              WHERE LabId = %s
#              ORDER BY ActivityDescription
#         """, (lab_id,))
#         st.subheader("Activities and funds")
#         acts = cur.fetchall()
#         st.dataframe(pd.DataFrame(acts), use_container_width=True) if acts else \
#             st.info("This lab has no activities yet.")

#         # pending requests
#         cur.execute("""
#             SELECT r.RequestId AS `Req ID`, la.ActivityDescription AS Activity,
#                    r.RequestDate AS `Date`,
#                    COALESCE(CONCAT(i.Category,' / ',i.Make,' ',i.Model),'–') AS Item,
#                    r.QuantityRequested AS Qty
#               FROM Request r
#               JOIN LabActivity la ON la.ActivityId = r.ActivityId
#               LEFT JOIN Item i ON i.ItemId = r.ItemId
#              WHERE la.LabId = %s AND r.RequestStatus = 'Pending'
#              ORDER BY r.RequestDate DESC
#         """, (lab_id,))
#         st.subheader("Pending requests")
#         reqs = cur.fetchall()
#         st.dataframe(pd.DataFrame(reqs), use_container_width=True) if reqs else \
#             st.info("No pending requests in this lab")

#         # open POs
#         cur.execute("""
#             SELECT po.POId AS `PO ID`, la.ActivityDescription AS Activity,
#                    po.OrderDate AS `Order Date`, po.Amount AS `Amount (₹)`,
#                    po.POStatus AS Status
#               FROM PurchaseOrder po
#               JOIN LabActivity la ON la.ActivityId = po.ActivityId
#              WHERE la.LabId = %s AND po.POStatus <> 'Closed'
#              ORDER BY po.OrderDate DESC
#         """, (lab_id,))
#         st.subheader("Open purchase orders")
#         pos = cur.fetchall()
#         st.dataframe(pd.DataFrame(pos), use_container_width=True) if pos else \
#             st.info("No open POs in this lab")

#         # lab funds history chart
#         cur.execute("""
#             SELECT DateCreated AS log_date,
#                    CASE WHEN ActionTaken IN ('Added','Refunded') THEN  Amount
#                         WHEN ActionTaken = 'Allocated'          THEN -Amount
#                         ELSE 0 END AS delta
#               FROM LabLog
#              WHERE LabId = %s
#              ORDER BY DateCreated
#         """, (lab_id,))
#         fund_rows = cur.fetchall()
#         st.subheader("Lab funds history")
#         if fund_rows:
#             df = pd.DataFrame(fund_rows).rename(columns={"log_date":"Date","delta":"Δ"})
#             df["Funds"] = df["Δ"].cumsum(); df.set_index("Date", inplace=True)
#             st.line_chart(df[["Funds"]])
#         else:
#             st.info("No fund-movement history for this lab")
#     finally:
#         cur.close(); conn.close()


# ───────────────────────── APPROVALS ────────────────────────────
def request_approvals() -> None:
    """
    Lab assistant / HOD view to approve or reject *pending* requests.
    """
    st.header("Request approvals")

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # 1️⃣  pick a lab ----------------------------------------------------
        cur.execute("SELECT LabId, LabName FROM Lab ORDER BY LabName")
        lab_map = {row["LabName"]: row["LabId"] for row in cur.fetchall()}

        if not lab_map:
            st.warning("No labs in the system.")
            return

        lab_sel = st.selectbox("Lab", lab_map.keys())
        lab_id = lab_map[lab_sel]

        # 2️⃣  list *pending* requests for that lab -------------------------
        cur.execute(
            """
            SELECT r.RequestId                   AS `Req ID`,
                   la.ActivityDescription        AS `Activity`,
                   r.RequestDate                 AS `Date`,
                   COALESCE(CONCAT(i.Category,' / ',i.Make,' ',i.Model),'–') AS `Item`,
                   r.QuantityRequested           AS `Qty`
              FROM Request       r
              JOIN LabActivity   la ON la.ActivityId = r.ActivityId
              LEFT JOIN Item     i  ON i.ItemId      = r.ItemId
             WHERE la.LabId = %s
               AND r.RequestStatus = 'Pending'
             ORDER BY r.RequestDate
            """,
            (lab_id,),
        )
        rows = cur.fetchall()

        st.subheader("Pending requests")
        if not rows:
            st.success("Nothing waiting for approval in this lab.")
            return

        st.dataframe(pd.DataFrame(rows), use_container_width=True)

        # 3️⃣  select one request to act on ---------------------------------
        req_map = {
            f"{r['Req ID']} – {r['Item']} (qty {r['Qty']})": r["Req ID"] for r in rows
        }

        sel = st.selectbox("Choose a request", req_map.keys())
        req_id = req_map[sel]

        decision = st.radio("Decision", ("Approve", "Reject"), horizontal=True)

        if st.button("Submit decision"):
            try:
                cur.callproc(
                    "sp_approve_request",
                    [req_id, True if decision == "Approve" else False],
                )
                conn.commit()
                st.success(f"Request #{req_id} {decision.lower()}d.")
                st.rerun()
            except Exception as e:
                conn.rollback()
                st.error(f"Failed: {e}")

    finally:
        cur.close()
        conn.close()


# ───────────────────────── Purchase Orders ─────────────────────
def purchase_orders() -> None:
    """
    1. show all Approved requests for the chosen lab
    2. open a PO for one activity               → sp_create_PO
    3. add line-items                           → sp_log_PO_item
    """
    st.header("Purchase orders")

    # keep the “current” PO in session
    st.session_state.setdefault("po_id", None)
    st.session_state.setdefault("po_activity", None)

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # ─── pick a lab ────────────────────────────────────────────────
        cur.execute("SELECT LabId, LabName FROM Lab ORDER BY LabName")
        lab_map = {r["LabName"]: r["LabId"] for r in cur.fetchall()}
        lab_sel = st.selectbox("Lab", lab_map.keys())
        lab_id = lab_map[lab_sel]

        # ─── show Approved requests (informational) ────────────────────
        cur.execute(
            """
            SELECT r.RequestId AS `Req ID`,
                   r.ActivityId,
                   r.ItemId,
                   r.QuantityRequested AS Qty
              FROM Request r
             WHERE r.RequestStatus = 'Approved'
               AND EXISTS (
                    SELECT 1 FROM LabActivity la
                     WHERE la.ActivityId = r.ActivityId
                       AND la.LabId = %s
               )
             ORDER BY r.RequestId
        """,
            (lab_id,),
        )
        req_rows = cur.fetchall()
        st.subheader("Approved requests (awaiting PO)")
        if req_rows:
            st.dataframe(pd.DataFrame(req_rows), use_container_width=True)
        else:
            st.info("No approved requests for this lab.")

        # ─── OPEN A NEW PO ─────────────────────────────────────────────
        st.markdown("## Open a new PO")

        # activities that have approved requests
        act_ids = sorted({r["ActivityId"] for r in req_rows})
        if not act_ids:
            st.info("Nothing to order.")
            return

        act_map = {f"Activity {aid}": aid for aid in act_ids}
        act_sel = st.selectbox("Activity to order for", act_map.keys())
        activity_id = act_map[act_sel]

        if st.button("Open PO for this activity"):
            try:
                # use CALL + SELECT OUT_PARAM
                cur.execute("CALL sp_create_PO(%s, @new_po);", (activity_id,))
                cur.execute("SELECT @new_po;")
                po_id = cur.fetchone()["@new_po"]
                if not po_id:
                    raise RuntimeError("no PO id returned")
                conn.commit()

                st.session_state.po_id = po_id
                st.session_state.po_activity = activity_id
                st.success(f"PO #{po_id} opened for Activity {activity_id}.")
            except Exception as e:
                conn.rollback()
                st.error(f"Could not open PO: {e}")

        # ─── ADD LINE-ITEMS ────────────────────────────────────────────
        po_id = st.session_state.po_id
        if po_id is None:
            st.info("Open a PO above, then add line-items.")
            return

        st.markdown("---")
        st.markdown(f"### Add items to **PO #{po_id}**")

        cur.execute("SELECT ItemId FROM Item WHERE IsActive = 1 ORDER BY ItemId")
        item_choices = [str(r["ItemId"]) for r in cur.fetchall()]

        with st.form("add_line"):
            c1, c2, c3 = st.columns([2, 2, 2])
            with c1:
                item_id_str = st.selectbox("ItemId", item_choices)
            with c2:
                qty = st.number_input("Qty", min_value=1, step=1, value=1)
            with c3:
                cpu = st.number_input("Cost / unit (₹)", min_value=0.0, value=0.0)
            add_submitted = st.form_submit_button("Add line-item")

        if add_submitted:
            try:
                cur.execute(
                    "CALL sp_log_PO_item(%s, %s, %s, %s);",
                    (po_id, int(item_id_str), qty, cpu),
                )
                conn.commit()
                st.success("Item added.")
            except Exception as e:
                conn.rollback()
                st.error(f"Add failed: {e}")

        # ─── show current PO lines ─────────────────────────────────────
        cur.execute(
            """
            SELECT ItemId,
                   QuantityOrdered AS Qty,
                   CostPerUnit   AS CPU
              FROM POItem
             WHERE POId = %s
        """,
            (po_id,),
        )
        po_lines = cur.fetchall()
        if po_lines:
            st.markdown("#### Current line-items")
            st.dataframe(pd.DataFrame(po_lines), use_container_width=True)

    finally:
        cur.close()
        conn.close()


# ───────────────────────── PO APPROVALS PAGE ─────────────────────
def po_approvals() -> None:
    """
    1) Show all POs with status='Pending' → let user process them (approve/reject via sp_approve_PO).
    2) Show all POs with status='Approved' → let user close them by calling sp_receive_items.
    """
    st.header("PO Approvals")
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        # 1️⃣ Pending POs to process
        cur.execute(
            """
            SELECT POId                   AS `PO ID`,
                   ActivityId             AS `Activity`,
                   OrderDate              AS `Order Date`,
                   Amount                 AS `Amount (₹)`,
                   POStatus               AS `Status`
              FROM PurchaseOrder
             WHERE POStatus = 'Pending'
             ORDER BY OrderDate DESC
        """
        )
        pending = cur.fetchall()
        st.subheader("Pending purchase orders")
        if pending:
            df_pend = pd.DataFrame(pending)
            st.dataframe(df_pend, use_container_width=True)

            pend_map = {str(r["PO ID"]): r["PO ID"] for r in pending}
            sel_po = st.selectbox(
                "Select PO to process", pend_map.keys(), key="pend_po"
            )
            if st.button("Approve / Reject PO"):
                try:
                    cur.callproc("sp_approve_PO", [pend_map[sel_po]])
                    conn.commit()
                    st.success(f"PO #{pend_map[sel_po]} processed.")
                    st.rerun()
                except Exception as e:
                    conn.rollback()
                    st.error(f"Failed to process PO: {e}")
        else:
            st.info("No pending POs to process.")

        st.markdown("---")

        # 2️⃣ Approved POs to close (receive items)
        cur.execute(
            """
            SELECT POId                   AS `PO ID`,
                   ActivityId             AS `Activity`,
                   OrderDate              AS `Order Date`,
                   Amount                 AS `Amount (₹)`,
                   POStatus               AS `Status`
              FROM PurchaseOrder
             WHERE POStatus = 'Approved'
             ORDER BY OrderDate DESC
        """
        )
        approved = cur.fetchall()
        st.subheader("Approved purchase orders (ready to close)")
        if approved:
            df_app = pd.DataFrame(approved)
            st.dataframe(df_app, use_container_width=True)

            app_map = {str(r["PO ID"]): r["PO ID"] for r in approved}
            sel_app = st.selectbox("Select PO to close", app_map.keys(), key="app_po")

            with st.form("close_po_form"):
                storage_loc = st.text_input("Storage Location")
                short_desc = st.text_input("Short Description")
                serial_no = st.text_input("Serial No")
                submit_close = st.form_submit_button("Close PO")

            if submit_close:
                try:
                    cur.callproc(
                        "sp_receive_items",
                        [app_map[sel_app], storage_loc, short_desc, serial_no],
                    )
                    conn.commit()
                    st.success(f"PO #{app_map[sel_app]} closed and items received.")
                    st.rerun()
                except Exception as e:
                    conn.rollback()
                    st.error(f"Failed to close PO: {e}")
        else:
            st.info("No approved POs to close.")

    finally:
        cur.close()
        conn.close()


# ───────────────────────── REPORTS ───────────────────────────
def reports() -> None:
    """
    Show:
      1. activities & their current funds
      2. pending (Generated / Pending) requests
      3. open purchase-orders   (POStatus <> 'Closed')
      4. lab-funds history line chart          ─ derived from LabLog
    """
    import pandas as pd

    st.header("Lab-level reports")

    conn = get_connection()
    cur = conn.cursor(dictionary=True)

    try:
        # 1️⃣  choose a lab --------------------------------------------------
        cur.execute("SELECT LabId, LabName FROM Lab ORDER BY LabName")
        lab_map = {row["LabName"]: row["LabId"] for row in cur.fetchall()}

        if not lab_map:
            st.warning("No labs found in the system.")
            return

        lab_sel = st.selectbox("Lab", lab_map.keys())
        lab_id = lab_map[lab_sel]

        # 2️⃣  activities & funds -------------------------------------------
        cur.execute(
            """
            SELECT ActivityId          AS `ID`,
                   ActivityDescription AS `Activity`,
                   FundsAvailable      AS `Funds Available`
              FROM LabActivity
             WHERE LabId = %s
             ORDER BY ActivityDescription
            """,
            (lab_id,),
        )
        acts = cur.fetchall()

        st.subheader("Activities and funds")
        if acts:
            st.dataframe(pd.DataFrame(acts), use_container_width=True)
        else:
            st.info("This lab has no activities yet.")

        # 3️⃣  pending requests (status = Pending / Generated) --------------
        cur.execute(
            """
            SELECT r.RequestId                   AS `Req ID`,
                   la.ActivityDescription        AS `Activity`,
                   r.RequestDate                 AS `Date`,
                   COALESCE(CONCAT(i.Category,
                                   ' / ',
                                   i.Make,' ',
                                   i.Model),'–')              AS `Item`,
                   r.QuantityRequested           AS `Qty`
              FROM Request       r
              JOIN LabActivity   la ON la.ActivityId = r.ActivityId
              LEFT JOIN Item     i  ON i.ItemId      = r.ItemId
             WHERE la.LabId       = %s
               AND r.RequestStatus IN ('Generated','Pending')
             ORDER BY r.RequestDate DESC
            """,
            (lab_id,),
        )
        pending_reqs = cur.fetchall()

        st.subheader("Pending requests")
        if pending_reqs:
            st.dataframe(pd.DataFrame(pending_reqs), use_container_width=True)
        else:
            st.info("No pending requests in this lab")

        # 4️⃣  open purchase orders (every PO whose status ≠ Closed) --------
        cur.execute(
            """
            SELECT  po.POId                 AS `PO ID`,
                    la.ActivityDescription  AS `Activity`,
                    po.OrderDate            AS `Order Date`,
                    po.Amount               AS `Amount (₹)`,
                    po.POStatus             AS `Status`
              FROM  PurchaseOrder po
              JOIN  LabActivity   la ON la.ActivityId = po.ActivityId
             WHERE  la.LabId   = %s
               AND  po.POStatus <> 'Closed'
             ORDER BY po.OrderDate DESC
            """,
            (lab_id,),
        )
        open_pos = cur.fetchall()

        st.subheader("Open purchase orders")
        if open_pos:
            st.dataframe(pd.DataFrame(open_pos), use_container_width=True)
        else:
            st.info("No open POs in this lab")

        # 5️⃣  time-series: lab funds over time -----------------------------
        cur.execute(
            """
            SELECT DateCreated AS log_date,
                   CASE
                       WHEN ActionTaken IN ('Added','Refunded') THEN  Amount
                       WHEN ActionTaken =  'Allocated'          THEN -Amount
                       ELSE 0
                   END AS delta
              FROM LabLog
             WHERE LabId = %s
             ORDER BY DateCreated
            """,
            (lab_id,),
        )
        fund_rows = cur.fetchall()

        st.subheader("Lab funds history")
        if fund_rows:
            df = pd.DataFrame(fund_rows).rename(
                columns={"log_date": "Date", "delta": "Δ Funds"}
            )
            df["Funds"] = df["Δ Funds"].cumsum()  # running balance
            df.set_index("Date", inplace=True)

            st.line_chart(df[["Funds"]])
        else:
            st.info("No fund-movement history for this lab")

    finally:
        cur.close()
        conn.close()


# ───────────────────────── SQL CONSOLE ──────────────────────────
def sql_console():
    st.header("SQL Console")
    q = st.text_area("Enter SQL", height=150)
    if st.button("Run Query"):
        con = get_connection()
        cur = con.cursor()
        try:
            cur.execute(q)
            if cur.with_rows:
                st.dataframe(
                    pd.DataFrame(
                        cur.fetchall(), columns=[d[0] for d in cur.description]
                    ),
                    use_container_width=True,
                )
            else:
                con.commit()
                st.success(f"{cur.rowcount} row(s) affected.")
        except Exception as e:
            st.error(e)
        finally:
            cur.close()
            con.close()


# ───────────────────────── MAIN ────────────────────────────────
if "user_role" not in st.session_state:
    st.session_state.user_role = None
if st.session_state.user_role is None:
    login_screen()
else:
    st.sidebar.write(f"Logged in as: {st.session_state.user_role}")
    if st.sidebar.button("Logout"):
        st.session_state.user_role = None
    else:
        navigation()
