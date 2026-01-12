let myChart = null;

const CHART_CONFIG = {
    "popular_brands": { labelKey: "BrandName", dataKey: "LaptopCount", type: "pie", title: "Market Share by Brand" }, 
    "total_orders_by_user": { labelKey: "Email", dataKey: "TotalSpent", type: "bar", title: "Top Spenders" },
    "popular_categories": { labelKey: "CategoryName", dataKey: "ProductCount", type: "doughnut", title: "Products per Category" },
    "total_stock_by_brand": { labelKey: "BrandName", dataKey: "TotalStock", type: "bar", title: "Stock Levels" },
    "average_price_by_category": { labelKey: "CategoryName", dataKey: "AvgPrice", type: "bar", title: "Average Price" },
    
    "most_expensive_laptop_by_brand": { labelKey: "BrandName", dataKey: "MaxPrice", type: "bar", title: "Most Expensive Models" },
    "users_with_high_spending": { labelKey: "FirstName", dataKey: "TotalSpent", type: "bar", title: "High Value Customers" },
    
    "categories_with_high_stock": { labelKey: "CategoryName", dataKey: "TotalStock", type: "pie", title: "Overstocked Categories" },
    
    "brand_revenue": { labelKey: "BrandName", dataKey: "Revenue", type: "pie", title: "Revenue Share" },
    "unsold_inventory_risk": { labelKey: "ModelName", dataKey: "StockQuantity", type: "bar", title: "Risk Inventory" },
    
    "regional_top_selling": { labelKey: "CompositeLabel", dataKey: "TotalRevenue", type: "bar", title: "Top Selling by Region" }, 
    "monthly_category_revenue": { labelKey: "CompositeLabel", dataKey: "TotalRevenue", type: "line", title: "Revenue Trends" },
    "restock_advice": { labelKey: "ModelName", dataKey: "StockQuantity", type: "bar", title: "Stock vs Safety Level" },
    "vip_brand_affinity": { labelKey: "CustomerName", dataKey: "TotalUserSpend", type: "bar", title: "VIP Spending" },
    "loyalty_reward_tiers": { labelKey: "CustomerName", dataKey: "TotalSpent", type: "bar", title: "Loyalty Candidates Spending" },
    "lagging_flagships": { labelKey: "ModelName", dataKey: "TotalUnitsSold", type: "bar", title: "Sales of Expensive Models vs Avg" }
};

const REPORT_PARAMS = {
  laptops_by_brand: [{ name: "BrandName", label: "Brand Name", type: "text", placeholder: "e.g. Dell" }],
  popular_brands: [{ name: "MinCount", label: "Minimum Laptops in Brand", type: "number" }],
  total_orders_by_user: [{ name: "MinTotalAmount", label: "Minimum Order Amount", type: "number", step: "0.01" }],
  popular_categories: [{ name: "MinCount", label: "Minimum Laptops in Category", type: "number" }],
  total_stock_by_brand: [{ name: "BrandName", label: "Brand Name", type: "text" }],
  average_price_by_category: [{ name: "CategoryName", label: "Category Name", type: "text" }],
  most_expensive_laptop_by_brand: [{ name: "BrandName", label: "Brand Name", type: "text" }],
  users_with_high_spending: [{ name: "MinAmount", label: "Minimum Total Spent", type: "number", step: "0.01" }],
  laptops_not_in_cart: [{ name: "MinPrice", label: "Minimum Price", type: "number", step: "0.01" }],
  categories_with_high_stock: [{ name: "MinPrice", label: "Minimum Price", type: "number", step: "0.01" }],
  no_payment_users: [{ name: "Year", label: "Year (e.g. 2024)", type: "number" }],

  brand_revenue: [
    { name: "StartDate", label: "Start Date", type: "date" },
    { name: "EndDate", label: "End Date", type: "date" },
    { name: "MinRevenue", label: "Minimum Revenue", type: "number", step: "0.01" }
  ],
  unsold_inventory_risk: [{ name: "MinUnits", label: "Minimum Units in Stock", type: "number" }],
  
  monthly_category_revenue: [
    { name: "Year", label: "Year (e.g. 2024)", type: "number" }
  ],
  restock_advice: [
    { name: "SafetyStockThreshold", label: "Safety Stock Level", type: "number" }
  ],
  vip_brand_affinity: [
    { name: "StartDate", label: "Start Date", type: "date" },
    { name: "EndDate", label: "End Date", type: "date" },
    { name: "MinTotalSpend", label: "Minimum Total Spent", type: "number", step: "0.01" }
  ],
  regional_top_selling: [
    { name: "StartDate", label: "Start Date", type: "date" },
    { name: "EndDate", label: "End Date", type: "date" }
  ],
  loyalty_reward_tiers: [
        { name: "MinTotalSpend", label: "Minimum Total Spend", type: "number", step: "0.01" },
        { name: "LookbackDate", label: "Orders Since", type: "date" }
    ],
    lagging_flagships: [
        { name: "MinPrice", label: "Minimum Product Price", type: "number", step: "0.01" }
    ]
};

document.addEventListener("DOMContentLoaded", () => {
  const forms = [
      { id: "addUserForm", url: "/admin/add_user" },
      { id: "removeUserForm", url: "/admin/remove_user" },
      { id: "modifyUserForm", url: "/admin/modify_user" },
      { id: "addCategoryForm", url: "/admin/add_category" },
      { id: "removeCategoryForm", url: "/admin/remove_category" },
      { id: "updateCategoryForm", url: "/admin/update_category" },
      { id: "addLaptopForm", url: "/admin/add_laptop" }
  ];

  forms.forEach(formInfo => {
      const formEl = document.getElementById(formInfo.id);
      if(formEl) {
          formEl.addEventListener("submit", async (event) => {
              event.preventDefault();
              const formData = new FormData(event.target);
              const data = Object.fromEntries(formData.entries());
              
              try {
                  const response = await fetch(formInfo.url, {
                      method: "POST",
                      headers: { "Content-Type": "application/json" },
                      body: JSON.stringify(data),
                  });
                  const result = await response.json();
                  alert(result.message);
                  if(result.success) event.target.reset();
              } catch (e) {
                  alert("Error submitting form: " + e);
              }
          });
      }
  });

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
    
    const chartContainer = document.querySelector('.chart-container');
    if (chartContainer) chartContainer.style.display = 'none';
  });

  executeQueryButton.addEventListener("click", () => {
    executeQuery(querySelect.value);
  });
});

function removeLaptopByName() {
  const modelName = document.getElementById('laptopNameInput').value.trim();

  if (!modelName) {
    alert('Please enter a valid laptop name.');
    return;
  }

  fetch('/admin/remove_laptop', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ModelName: modelName }),
  })
    .then(response => response.json())
    .then(data => {
        alert(data.message);
    })
    .catch(error => {
      console.error('Error:', error);
      alert('An unexpected error occurred.');
    });
}

async function executeQuery(queryName) {
  const chartContainer = document.querySelector('.chart-container');
  if (chartContainer) chartContainer.style.display = 'none';

  const defs = REPORT_PARAMS[queryName] || [];
  const params = new URLSearchParams();

  defs.forEach(def => {
    const val = (document.getElementById(`param-${def.name}`)?.value || "").trim();
    if (val !== "") params.append(def.name, val);
  });

  try {
    const url = `/admin/execute_query/${encodeURIComponent(queryName)}${params.toString() ? "?" + params.toString() : ""}`;
    const response = await fetch(url);
    const data = await response.json();

    const resultsTable = document.getElementById('results-table');
    resultsTable.innerHTML = '';

    if (data.success) {
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

        renderChart(data.results, queryName);

      } else {
        resultsTable.innerHTML = '<tr><td>No results found</td></tr>';
        if (myChart) myChart.destroy();
      }
    } else {
      alert(data.message);
    }
  } catch (error) {
    console.error('Error executing query:', error);
  }
}

function renderChart(data, reportType) {
  const canvas = document.getElementById('reportChart');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  const chartContainer = document.querySelector('.chart-container');

  const config = CHART_CONFIG[reportType];
  
  if (!config) {
      chartContainer.style.display = 'none';
      if(myChart) myChart.destroy();
      return; 
  }

  if (myChart) {
    myChart.destroy();
  }

  const labels = data.map(item => {
      if (reportType === 'regional_top_selling') {
          return `${item.City} - ${item.ModelName}`;
      }
      if (reportType === 'monthly_category_revenue') {
          return `${item.CategoryName} (Month ${item.SaleMonth})`;
      }
      const key = Object.keys(item).find(k => k.toLowerCase() === config.labelKey.toLowerCase());
      return key ? item[key] : "Unknown";
  });

  const values = data.map(item => {
      const key = Object.keys(item).find(k => k.toLowerCase() === config.dataKey.toLowerCase());
      return key ? item[key] : 0;
  });
  chartContainer.style.display = 'block';

  const bgColors = values.map((_, i) => `hsla(${ (i * 360) / values.length }, 70%, 50%, 0.6)`);
  const borderColors = values.map((_, i) => `hsla(${ (i * 360) / values.length }, 70%, 50%, 1)`);

  myChart = new Chart(ctx, {
    type: config.type || 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: config.title || reportType,
        data: values,
        backgroundColor: bgColors,
        borderColor: borderColors,
        borderWidth: 1,
        fill: config.type === 'line' ? false : true
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          display: config.type !== 'pie' && config.type !== 'doughnut'
        },
        x: {
          display: config.type !== 'pie' && config.type !== 'doughnut'
        }
      },
      plugins: {
        title: {
          display: true,
          text: (config.title || reportType).toUpperCase()
        },
        legend: {
            display: config.type === 'pie' || config.type === 'doughnut'
        }
      }
    }
  });
}