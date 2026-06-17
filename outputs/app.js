const DEFAULT_CONFIG = {
  SUPABASE_URL: "",
  SUPABASE_ANON_KEY: "",
  SUPABASE_SCHEMA: "espetinho_gordinho",
  OWNER_PASSWORD: "Espetinho@2026",
  PIX_KEY: "63.512.299/0001-83",
  PIX_NAME: "Francisco Dionísio"
};

const CONFIG = { ...DEFAULT_CONFIG, ...(window.ESPETINHO_CONFIG || {}) };
const money = value => Number(value || 0).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
const byId = id => document.getElementById(id);
const localKey = "espetinho_local_data_v1";
let supabaseClient = null;

const seed = {
  categories: [
    { id: "comida", name: "Comida", sort_order: 10 },
    { id: "bebidas", name: "Bebidas", sort_order: 20 },
    { id: "cerveja", name: "Cerveja", sort_order: 30 },
    { id: "quentes", name: "Bebidas quentes", sort_order: 40 }
  ],
  products: [
    ["comida", "Baião cremoso", "Vai com farofa e vinagrete", 7, "P"], ["comida", "Baião cremoso", "Vai com farofa e vinagrete", 12, "G"],
    ["comida", "Batatinha frita", "", 8, "P"], ["comida", "Batatinha frita", "", 14, "G"], ["comida", "Macaxeira", "", 12, ""],
    ["comida", "Espetinho de porco", "", 6, ""], ["comida", "Espetinho de gado", "", 6, ""], ["comida", "Espetinho de coxa", "", 6, ""],
    ["comida", "Espetinho de asinha", "", 6, ""], ["comida", "Espetinho de coração de frango", "", 6, ""], ["comida", "Lasanha de carne moída", "", 13, ""],
    ["comida", "Fricassê", "", 13, ""], ["comida", "Torta de frango", "", 13, ""], ["comida", "Macarronada", "", 13, ""], ["comida", "Escondidinho de carne moída", "", 13, ""],
    ["bebidas", "Coca-Cola", "1L", 10, "1L"], ["bebidas", "Coca-Cola Zero", "1L", 10, "1L"], ["bebidas", "São Geraldo", "1L", 10, "1L"],
    ["bebidas", "Coca-Cola lata", "", 5, ""], ["bebidas", "Coca-Cola Zero lata", "", 5, ""], ["bebidas", "Fanta Uva", "", 5, ""], ["bebidas", "Fanta Laranja", "", 5, ""],
    ["bebidas", "Guaraná lata", "", 5, ""], ["bebidas", "Sprite", "", 5, ""], ["bebidas", "Água sem gás", "", 3, ""], ["bebidas", "Água com gás", "", 4, ""],
    ["cerveja", "Skol", "300ml", 5, "300ml"], ["cerveja", "Brahma Chopp", "300ml", 5, "300ml"], ["cerveja", "Michelob Ultra", "330ml", 10, "330ml"],
    ["cerveja", "Budweiser", "600ml", 12, "600ml"], ["cerveja", "Spaten", "600ml", 12, "600ml"],
    ["quentes", "Cana 51", "", 30, ""], ["quentes", "Terça de 51", "", 5, ""], ["quentes", "Dreher", "", 40, ""],
    ["quentes", "Terça", "", 7, ""], ["quentes", "Red Label", "", 125, ""], ["quentes", "Black & White", "", 100, ""]
  ].map((p, i) => ({ id: `p${i}`, category_id: p[0], name: p[1], description: p[2], price: p[3], size: p[4], sold_out: false, active: true, sort_order: i }))
};

const productNameFixes = {
  "Baiao cremoso": "Baião cremoso",
  "Espetinho de coracao de frango": "Espetinho de coração de frango",
  "Lasanha de carne moida": "Lasanha de carne moída",
  "Fricasse": "Fricassê",
  "Escondidinho de carne moida": "Escondidinho de carne moída",
  "Coca cola": "Coca-Cola",
  "Coca cola zero": "Coca-Cola Zero",
  "Sao Geraldo": "São Geraldo",
  "Coca lata": "Coca-Cola lata",
  "Coca lata zero": "Coca-Cola Zero lata",
  "Fanta uva": "Fanta Uva",
  "Fanta laranja": "Fanta Laranja",
  "Guarana lata": "Guaraná lata",
  "Agua sem gas": "Água sem gás",
  "Agua com gas": "Água com gás",
  "Brahma chopp": "Brahma Chopp",
  "Michelob ultra": "Michelob Ultra",
  "Terca de 51": "Terça de 51",
  "Dreia": "Dreher",
  "Terca": "Terça",
  "Red label": "Red Label",
  "Black white": "Black & White"
};

function normalizeProductKey(product) {
  return [
    product.category_id || "",
    String(product.name || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().trim(),
    String(product.size || "").toLowerCase().trim(),
    Number(product.price || 0).toFixed(2)
  ].join("|");
}

function migrateLocalData(data) {
  let changed = false;
  data.products = (data.products || []).map(product => {
    const fixed = productNameFixes[product.name];
    if (!fixed) return product;
    changed = true;
    return { ...product, name: fixed };
  });
  const seen = new Set();
  data.products = data.products.filter(product => {
    const key = normalizeProductKey(product);
    if (seen.has(key)) {
      changed = true;
      return false;
    }
    seen.add(key);
    return true;
  });
  if (changed) localStorage.setItem(localKey, JSON.stringify(data));
  return data;
}

function cleanProducts(products) {
  const seen = new Set();
  return (products || [])
    .map(product => productNameFixes[product.name] ? { ...product, name: productNameFixes[product.name] } : product)
    .filter(product => {
      const key = normalizeProductKey(product);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
}

function getDb() {
  const raw = localStorage.getItem(localKey);
  if (raw) return migrateLocalData(JSON.parse(raw));
  const data = { ...seed, orders: [], items: [] };
  localStorage.setItem(localKey, JSON.stringify(data));
  return data;
}

function setDb(data) {
  localStorage.setItem(localKey, JSON.stringify(data));
  window.dispatchEvent(new StorageEvent("storage", { key: localKey }));
}

function hasSupabase() {
  return CONFIG.SUPABASE_URL && CONFIG.SUPABASE_ANON_KEY && window.supabase;
}

function sb() {
  if (!hasSupabase()) return null;
  if (!supabaseClient) supabaseClient = window.supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);
  return supabaseClient;
}

function db(table) {
  const client = sb();
  if (!client) return null;
  if (!CONFIG.SUPABASE_SCHEMA || CONFIG.SUPABASE_SCHEMA === "public") return client.from(table);
  return client.schema(CONFIG.SUPABASE_SCHEMA).from(table);
}

async function loadMenu() {
  const client = sb();
  if (!client) {
    const data = getDb();
    return { categories: data.categories, products: cleanProducts(data.products.filter(p => p.active !== false)) };
  }
  const [{ data: categories, error: cErr }, { data: products, error: pErr }] = await Promise.all([
    db("espetinho_categories").select("*").eq("active", true).order("sort_order"),
    db("espetinho_products").select("*").eq("active", true).order("sort_order")
  ]);
  if (cErr || pErr) throw new Error((cErr || pErr).message);
  return { categories, products: cleanProducts(products) };
}

async function createOrder(payload, cart) {
  const subtotal = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const total = subtotal + Number(payload.delivery_fee || 0);
  const order = { ...payload, subtotal, total, status: payload.channel === "mesa" ? "aberto" : "novo" };
  const client = sb();
  if (!client) {
    const data = getDb();
    const existing = payload.channel === "mesa"
      ? data.orders.find(o => o.channel === "mesa" && o.table_number === payload.table_number && o.status === "aberto")
      : null;
    if (existing) {
      existing.subtotal = Number(existing.subtotal || 0) + subtotal;
      existing.total = Number(existing.total || 0) + subtotal;
      existing.updated_at = new Date().toISOString();
      cart.forEach(item => data.items.push({
        id: crypto.randomUUID(), order_id: existing.id, product_id: item.id, product_name: displayName(item),
        unit_price: item.price, quantity: item.quantity, notes: item.notes || "", removed: false, created_at: existing.updated_at
      }));
      setDb(data);
      return { ...existing, items: data.items.filter(i => i.order_id === existing.id && !i.removed) };
    }
    order.id = crypto.randomUUID();
    order.order_code = order.id.slice(0, 6).toUpperCase();
    order.created_at = new Date().toISOString();
    order.updated_at = order.created_at;
    data.orders.unshift(order);
    cart.forEach(item => data.items.push({
      id: crypto.randomUUID(), order_id: order.id, product_id: item.id, product_name: displayName(item),
      unit_price: item.price, quantity: item.quantity, notes: item.notes || "", removed: false, created_at: order.created_at
    }));
    setDb(data);
    return { ...order, items: data.items.filter(i => i.order_id === order.id) };
  }
  if (payload.channel === "mesa") {
    const { data: existing } = await client
      .schema(CONFIG.SUPABASE_SCHEMA || "public")
      .from("espetinho_orders")
      .select("*, items:espetinho_order_items(*)")
      .eq("channel", "mesa")
      .eq("table_number", payload.table_number)
      .eq("status", "aberto")
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (existing) {
      const rows = cart.map(item => ({
        order_id: existing.id, product_id: item.id, product_name: displayName(item), unit_price: item.price,
        quantity: item.quantity, notes: item.notes || ""
      }));
      const { data: items, error: itemError } = await db("espetinho_order_items").insert(rows).select("*");
      if (itemError) throw itemError;
      const updatedTotals = {
        subtotal: Number(existing.subtotal || 0) + subtotal,
        total: Number(existing.total || 0) + subtotal,
        updated_at: new Date().toISOString()
      };
      const { data: updated, error: updateError } = await client
        .schema(CONFIG.SUPABASE_SCHEMA || "public")
        .from("espetinho_orders")
        .update(updatedTotals)
        .eq("id", existing.id)
        .select("*")
        .single();
      if (updateError) throw updateError;
      return { ...updated, items: [...(existing.items || []).filter(i => !i.removed), ...items] };
    }
  }
  const { data: inserted, error } = await db("espetinho_orders").insert(order).select("*").single();
  if (error) throw error;
  const rows = cart.map(item => ({
    order_id: inserted.id, product_id: item.id, product_name: displayName(item), unit_price: item.price,
    quantity: item.quantity, notes: item.notes || ""
  }));
  const { data: items, error: itemError } = await db("espetinho_order_items").insert(rows).select("*");
  if (itemError) throw itemError;
  return { ...inserted, items };
}

async function fetchOrders(statuses = []) {
  const client = sb();
  if (!client) {
    const data = getDb();
    let orders = data.orders;
    if (statuses.length) orders = orders.filter(o => statuses.includes(o.status));
    return orders.map(order => ({ ...order, items: data.items.filter(i => i.order_id === order.id && !i.removed) }));
  }
  let query = db("espetinho_orders").select("*, items:espetinho_order_items(*)").order("created_at", { ascending: false });
  if (statuses.length) query = query.in("status", statuses);
  const { data, error } = await query;
  if (error) throw error;
  return data.map(o => ({ ...o, items: (o.items || []).filter(i => !i.removed) }));
}

async function updateOrder(id, patch) {
  const client = sb();
  if (!client) {
    const data = getDb();
    data.orders = data.orders.map(o => o.id === id ? { ...o, ...patch, updated_at: new Date().toISOString() } : o);
    setDb(data);
    return;
  }
  const { error } = await db("espetinho_orders").update({ ...patch, updated_at: new Date().toISOString() }).eq("id", id);
  if (error) throw error;
}

async function removeItem(id) {
  const client = sb();
  if (!client) {
    const data = getDb();
    const item = data.items.find(i => i.id === id);
    if (item) item.removed = true;
    setDb(data);
    return;
  }
  const { error } = await db("espetinho_order_items").update({ removed: true }).eq("id", id);
  if (error) throw error;
}

function displayName(item) {
  return `${item.name}${item.size ? ` (${item.size})` : ""}`;
}

function isPublicOpen(date = new Date()) {
  const day = date.getDay();
  const minutes = date.getHours() * 60 + date.getMinutes();
  const windows = {
    3: [17 * 60 + 30, 23 * 60 + 59],
    4: [17 * 60 + 30, 23 * 60 + 59],
    5: [17 * 60 + 30, 23 * 60 + 59],
    6: [17 * 60 + 30, 23 * 60 + 59],
    0: [17 * 60 + 30, 23 * 60 + 59]
  };
  const range = windows[day];
  return !!range && minutes >= range[0] && minutes <= range[1];
}

function renderShell(active = "") {
  document.body.insertAdjacentHTML("afterbegin", `
    <div class="topbar">
      <div class="topbar-inner">
        <div class="brand">
          <img src="logo.png" alt="Espetinho do Gordinho">
          <div><strong>Espetinho do Gordinho</strong><span>${active}</span></div>
        </div>
        <nav class="nav">
          <a href="publico.html">Público</a>
          <a href="balcao.html">Balcão</a>
          <a href="mesas.html">Mesas</a>
          <a href="empresa.html">Empresa</a>
          <a href="proprietario.html">Proprietário</a>
        </nav>
      </div>
    </div>
  `);
}

function makeCart() {
  let cart = [];
  const add = product => {
    if (product.sold_out) return;
    const found = cart.find(i => i.id === product.id);
    if (found) found.quantity += 1;
    else cart.push({ ...product, quantity: 1 });
  };
  const change = (id, delta) => {
    cart = cart.map(i => i.id === id ? { ...i, quantity: i.quantity + delta } : i).filter(i => i.quantity > 0);
  };
  const clear = () => { cart = []; };
  const items = () => cart;
  return { add, change, clear, items };
}

function renderMenu(target, menu, cart, rerender) {
  target.innerHTML = menu.categories.map((cat, index) => {
    const products = menu.products.filter(p => p.category_id === cat.id);
    if (!products.length) return "";
    return `
      <section class="menu-section cat-${index % 6}">
        <div class="section-title"><h2>${cat.name}</h2></div>
        <div class="menu-list">
          ${products.map(p => `
            <article class="product ${p.sold_out ? "soldout" : ""}">
              <div>
                <h3>${displayName(p)}</h3>
                <p>${p.description || ""}</p>
              </div>
              <div class="actions">
                <span class="price">${money(p.price)}</span>
                <button ${p.sold_out ? "disabled" : ""} data-add="${p.id}">${p.sold_out ? "Esgotado" : "Adicionar"}</button>
              </div>
            </article>
          `).join("")}
        </div>
      </section>`;
  }).join("");
  target.querySelectorAll("[data-add]").forEach(btn => {
    btn.addEventListener("click", () => {
      const product = menu.products.find(p => p.id === btn.dataset.add);
      cart.add(product);
      rerender();
    });
  });
}

function renderCart(target, cart, options = {}) {
  const items = cart.items();
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  target.innerHTML = `
    <h2>Carrinho</h2>
    ${items.length ? items.map(item => `
      <div class="cart-line">
        <div><strong>${displayName(item)}</strong><br><span class="muted">${money(item.price)} cada</span></div>
        <div class="qty">
          <button data-dec="${item.id}">-</button><span>${item.quantity}</span><button data-inc="${item.id}">+</button>
        </div>
      </div>
    `).join("") : `<p class="muted">Clique nos produtos para montar o pedido.</p>`}
    <div class="totals">
      <div class="total-row"><span>Produtos</span><strong>${money(subtotal)}</strong></div>
      ${options.deliveryFee ? `<div class="total-row"><span>Entrega</span><strong>${money(options.deliveryFee)}</strong></div>` : ""}
      <div class="total-row final"><span>Total</span><strong>${money(subtotal + Number(options.deliveryFee || 0))}</strong></div>
    </div>`;
  target.querySelectorAll("[data-dec]").forEach(btn => btn.addEventListener("click", () => { cart.change(btn.dataset.dec, -1); options.onChange(); }));
  target.querySelectorAll("[data-inc]").forEach(btn => btn.addEventListener("click", () => { cart.change(btn.dataset.inc, 1); options.onChange(); }));
}

function receiptHtml(order) {
  const payment = {
    dinheiro: `DINHEIRO${order.change_for ? ` - LEVAR TROCO PARA ${money(order.change_for)}` : ""}`,
    cartao_credito: "CARTÃO DE CRÉDITO - LEVAR MAQUINETA",
    cartao: "CARTÃO - LEVAR MAQUINETA",
    pix: `PIX - ${CONFIG.PIX_KEY}`,
    pendente: "PENDENTE"
  }[order.payment_method] || order.payment_method;
  return `
    <div class="receipt">
      <h2>ESPETINHO DO GORDINHO</h2>
      <h3>Pedido ${order.order_code || order.id.slice(0, 6).toUpperCase()}</h3>
      <p><strong>Data:</strong> ${new Date(order.created_at || Date.now()).toLocaleString("pt-BR")}</p>
      <p><strong>Tipo:</strong> ${order.channel}${order.table_number ? ` - Mesa ${order.table_number}` : ""}</p>
      ${order.customer_name ? `<p><strong>Cliente:</strong> ${order.customer_name}</p>` : ""}
      ${order.customer_phone ? `<p><strong>Contato:</strong> ${order.customer_phone}</p>` : ""}
      ${order.customer_address ? `<p><strong>Endereço:</strong> ${order.customer_address}</p>` : ""}
      ${order.fulfillment ? `<p><strong>Entrega/Retirada:</strong> ${order.fulfillment}${order.delivery_area ? ` - ${order.delivery_area}` : ""}</p>` : ""}
      <hr>
      ${(order.items || []).map(i => `<p>${i.quantity}x ${i.product_name}<br><strong>${money(i.unit_price * i.quantity)}</strong></p>`).join("")}
      <hr>
      <p><strong>Subtotal:</strong> ${money(order.subtotal)}</p>
      ${Number(order.delivery_fee) ? `<p><strong>Entrega:</strong> ${money(order.delivery_fee)}</p>` : ""}
      <h3>TOTAL ${money(order.total)}</h3>
      <p><strong>Pagamento:</strong> ${payment}</p>
      ${order.notes ? `<p><strong>Obs:</strong> ${order.notes}</p>` : ""}
      <div class="cut">Corte automatico pelo driver da impressora</div>
    </div>`;
}

function printOrder(order) {
  let area = byId("printArea");
  if (!area) {
    area = document.createElement("div");
    area.id = "printArea";
    document.body.appendChild(area);
  }
  area.innerHTML = receiptHtml(order);
  window.print();
}

function showModal(title, body) {
  const modal = byId("modal") || document.body.appendChild(document.createElement("div"));
  modal.id = "modal";
  modal.className = "modal show";
  modal.innerHTML = `<div class="modal-card"><h2>${title}</h2>${body}<div class="actions"><button data-close-modal>OK</button></div></div>`;
  modal.querySelector("[data-close-modal]").addEventListener("click", () => modal.classList.remove("show"));
}

function requireOwner() {
  if (localStorage.getItem("espetinho_owner_ok") === "true") return true;
  const pass = prompt("Senha do proprietário");
  if (pass === CONFIG.OWNER_PASSWORD) {
    localStorage.setItem("espetinho_owner_ok", "true");
    return true;
  }
  location.href = "publico.html";
  return false;
}
