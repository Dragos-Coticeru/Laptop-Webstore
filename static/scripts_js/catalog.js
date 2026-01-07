function toggleDropdown() {
  document.getElementById("categoryDropdown").classList.toggle("show");
}

function loadCategories() {
  fetch('/get_categories', {
      method: 'GET',
      headers: {
          'X-Requested-With': 'XMLHttpRequest'
      }
  })
  .then(response => response.json())
  .then(categories => {
      const dropdownContent = document.getElementById('categoryDropdown');
      categories.forEach(category => {
          const a = document.createElement('a');
          a.innerText = category;
          a.href = "#";
          dropdownContent.appendChild(a);
      });
  })
  .catch(error => console.error('Error:', error));
}

function displayLaptops(laptops) {
  const laptopList = document.getElementById('laptop-list');
  laptopList.innerHTML = '';
  let row;
  laptops.forEach((laptop, index) => {
    if (index % 3 === 0) {
      row = document.createElement('div');
      row.classList.add('row');
      laptopList.appendChild(row);
    }
    const laptopCard = document.createElement('div');
    laptopCard.classList.add('laptop-card');
    const img = document.createElement('img');
    const imagePath = `/static/assets/laptop_pictures/${laptop.LaptopID}.jpg`;
    img.src = imagePath;
    img.alt = laptop.ModelName;
    img.onerror = () => {
      img.src = '/static/assets/laptop_pictures/default.jpg';
    };
    laptopCard.appendChild(img);
    const modelName = document.createElement('h4');
    modelName.innerText = laptop.ModelName;
    laptopCard.appendChild(modelName);
    const price = document.createElement('p');
    price.innerText = `Price: ${laptop.Price} Lei`;
    laptopCard.appendChild(price);
    const button = document.createElement('button');
    button.innerText = 'Add to Cart';
    button.onclick = () => addToCart(laptop.LaptopID);
    laptopCard.appendChild(button);
    row.appendChild(laptopCard);
  });
}

async function addToCart(laptopId) {
  try {
    const response = await fetch('/add_to_cart', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ laptop_id: laptopId }),
    });
    const data = await response.json();
    if (data.success) {
      alert('Laptop added to cart successfully!');
    } else {
      alert('Failed to add laptop to cart: ' + data.message);
    }
  } catch (error) {
    console.error('Error:', error);
    alert('An unexpected error occurred. Please try again.');
  }
}

async function searchLaptops() {
  const searchTerm = document.getElementById('search').value.trim();
  console.log("Searching for2:", searchTerm);
  try {
    const response = await fetch('/search_laptops', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ search_term: searchTerm }),
    });
    const data = await response.json();
    console.log(data);
    if (data.success) {
      displayLaptops(data.laptops);
    } else {
      console.error('Error searching laptops:', data.message);
      alert('Failed to search laptops. Please try again.');
    }
  } catch (error) {
    console.error('Error:', error);
    alert('An unexpected error occurred. Please try again.');
  }
}

document.addEventListener('DOMContentLoaded', async () => {
  try {
    const response = await fetch('/get_laptops');
    const laptops = await response.json();
    displayLaptops(laptops);
  } catch (error) {
    console.error('Error fetching laptops:', error);
  }
});

document.addEventListener('DOMContentLoaded', loadCategories);
document.addEventListener('DOMContentLoaded', displayLaptops);

window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {
    const dropdowns = document.getElementsByClassName("dropdown-content");
    for (let i = 0; i < dropdowns.length; i++) {
      const openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}