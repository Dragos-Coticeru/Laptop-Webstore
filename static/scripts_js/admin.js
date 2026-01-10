document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("addUserForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      const response = await fetch("/admin/add_user", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await response.json();
      alert(result.message);
    });
  
    document.getElementById("removeUserForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const email = new FormData(event.target).get("email");
      const response = await fetch("/admin/remove_user", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      const result = await response.json();
      alert(result.message);
    });
  
    document.getElementById("modifyUserForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      const response = await fetch("/admin/modify_user", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await response.json();
      alert(result.message);
    });
  
    document.getElementById("addCategoryForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      const response = await fetch("/admin/add_category", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await response.json();
      alert(result.message);
    });

    document.getElementById("removeCategoryForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const categoryName = new FormData(event.target).get("categoryName");
      const response = await fetch("/admin/remove_category", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ categoryName }),
      });
      const result = await response.json();
      alert(result.message);
    });

    document.getElementById("updateCategoryForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      const response = await fetch("/admin/update_category", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await response.json();
      alert(result.message);
    });

  
    document.getElementById("addLaptopForm").addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      const response = await fetch("/admin/add_laptop", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await response.json();
      alert(result.message);
    });

  });
  

function removeLaptopByName() {
    const modelName = document.getElementById('laptopNameInput').value.trim(); // Fetch input value

    if (!modelName) {
        alert('Please enter a valid laptop name.');
        return;
    }

    fetch('/admin/remove_laptop', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ModelName: modelName }),
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(data.message);
            } else {
                console.error(data.message);
                alert(`Error: ${data.message}`);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An unexpected error occurred.');
        });
}

async function executeQuery(queryName) {
    try {
      const response = await fetch(`/admin/execute_query/${queryName}`);
      const data = await response.json();
  
      if (data.success) {
        const resultsTable = document.getElementById('results-table');
        resultsTable.innerHTML = '';
  
        if (data.results.length > 0) {
          const headers = Object.keys(data.results[0]);
          const headerRow = document.createElement('tr');
          headers.forEach(header => {
            const th = document.createElement('th');
            th.innerText = header;
            headerRow.appendChild(th);
          });
          resultsTable.appendChild(headerRow);
  
          data.results.forEach(row => {
            const tr = document.createElement('tr');
            Object.values(row).forEach(value => {
              const td = document.createElement('td');
              td.innerText = value;
              tr.appendChild(td);
            });
            resultsTable.appendChild(tr);
          });
        } else {
          resultsTable.innerHTML = '<tr><td>No results found</td></tr>';
        }
      } else {
        alert(data.message);
      }
    } catch (error) {
      console.error('Error executing query:', error);
    }
  }

const REPORT_PARAMS = {
  laptops_by_brand: [{name:"BrandName", label:"Brand Name", type:"text", placeholder:"e.g. Dell"}],
  popular_brands: [{name:"MinCount", label:"Minimum Laptops in Brand", type:"number"}],
  total_orders_by_user: [{name:"MinTotalAmount", label:"Minimum Order Amount", type:"number", step:"0.01"}],
  popular_categories: [{name:"MinCount", label:"Minimum Laptops in Category", type:"number"}],
  total_stock_by_brand: [{name:"BrandName", label:"Brand Name", type:"text"}],
  average_price_by_category: [{name:"CategoryName", label:"Category Name", type:"text"}],
  most_expensive_laptop_by_brand: [{name:"BrandName", label:"Brand Name", type:"text"}],
  users_with_high_spending: [{name:"MinAmount", label:"Minimum Total Spent", type:"number", step:"0.01"}],
  laptops_not_in_cart: [{name:"MinPrice", label:"Minimum Price", type:"number", step:"0.01"}],
  categories_with_high_stock: [{name:"MinPrice", label:"Minimum Price", type:"number", step:"0.01"}],
  no_payment_users: [{name:"Year", label:"Year (e.g. 2024)", type:"number"}],

  brand_revenue: [
    {name:"StartDate",  label:"Start Date", type:"date"},
    {name:"EndDate",    label:"End Date", type:"date"},
    {name:"MinRevenue", label:"Minimum Revenue", type:"number", step:"0.01"}
  ],
  unsold_inventory_risk: [{name:"MinUnits", label:"Minimum Units in Stock", type:"number"}],
  monthly_category_revenue: [
    {name:"Year", label:"Year (e.g. 2024)", type:"number"}
  ],
  restock_advice: [
    {name:"SafetyStockThreshold", label:"Safety Stock Level", type:"number"}
  ],
  vip_brand_affinity: [
    {name:"StartDate", label:"Start Date", type:"date"},
    {name:"EndDate", label:"End Date", type:"date"},
    {name:"MinTotalSpend", label:"Minimum Total Spent", type:"number", step:"0.01"}
  ]
};

document.addEventListener("DOMContentLoaded", () => {
  const querySelect = document.getElementById("query-select");
  const queryInputContainer = document.getElementById("query-input-container");
  const executeQueryButton = document.getElementById("execute-query-button");

  function renderParamFields(reportKey) {
    queryInputContainer.innerHTML = "";
    const defs = REPORT_PARAMS[reportKey] || [];
    if (defs.length === 0) {
      queryInputContainer.style.display = "none";
      return;
    }
    queryInputContainer.style.display = "block";

    const row = document.createElement("div");
    row.className = "param-row";

    defs.forEach(def => {
      const wrap = document.createElement("div");
      wrap.className = "param-field";

      const label = document.createElement("label");
      label.setAttribute("for", `param-${def.name}`);
      label.textContent = def.label || def.name;

      const input = document.createElement("input");
      input.id = `param-${def.name}`;
      input.name = def.name;
      input.type = def.type || "text";
      if (def.placeholder) input.placeholder = def.placeholder;
      if (def.step) input.step = def.step;

      wrap.appendChild(label);
      wrap.appendChild(input);
      row.appendChild(wrap);
    });

    queryInputContainer.appendChild(row);
  }

  renderParamFields(querySelect.value);
  executeQueryButton.style.display = "block";

  querySelect.addEventListener("change", () => {
    renderParamFields(querySelect.value);
    executeQueryButton.style.display = "block";
  });

  executeQueryButton.addEventListener("click", async () => {
    const reportKey = querySelect.value;
    const defs = REPORT_PARAMS[reportKey] || [];
    const params = new URLSearchParams();

    defs.forEach(def => {
      const val = (document.getElementById(`param-${def.name}`)?.value || "").trim();
      if (val !== "") params.append(def.name, val);
    });

    try {
      const url = `/admin/execute_query/${encodeURIComponent(reportKey)}${params.toString() ? "?" + params.toString() : ""}`;
      const response = await fetch(url);
      const data = await response.json();

      const resultsTable = document.getElementById("results-table");
      resultsTable.innerHTML = "";

      if (data.success && data.results && data.results.length > 0) {
        const headers = Object.keys(data.results[0]);
        const headerRow = document.createElement("tr");
        headers.forEach(h => {
          const th = document.createElement("th");
          th.innerText = h;
          headerRow.appendChild(th);
        });
        resultsTable.appendChild(headerRow);

        data.results.forEach(row => {
          const tr = document.createElement("tr");
          Object.values(row).forEach(value => {
            const td = document.createElement("td");
            td.innerText = value;
            tr.appendChild(td);
          });
          resultsTable.appendChild(tr);
        });
      } else {
        resultsTable.innerHTML = "<tr><td>No results found</td></tr>";
      }
    } catch (error) {
      console.error("Error executing report:", error);
      alert("Error executing report.");
    }
  });
});