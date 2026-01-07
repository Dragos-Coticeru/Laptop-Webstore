async function loadCartItems() {
  try {
    const response = await fetch('/get_cart_items');
    const data = await response.json();
    if (data.success) {
      const cartItems = data.items;
      const cartContainer = document.getElementById('cart-items');
      cartContainer.innerHTML = '';
      let totalPrice = 0;
      cartItems.forEach(item => {
        const cartItem = document.createElement('div');
        cartItem.classList.add('cart-item');
        const itemDetails = document.createElement('div');
        itemDetails.innerHTML = `
          <h4>${item.model_name}</h4>
          <p>Price: ${item.price} Lei</p>
          <p>Quantity: ${item.quantity}</p>
        `;
        cartItem.appendChild(itemDetails);
        totalPrice += item.price * item.quantity;
        cartContainer.appendChild(cartItem);
      });
      const totalPriceElement = document.getElementById('total-price');
      totalPriceElement.innerText = `Total: ${totalPrice.toFixed(2)} Lei`;
    } else {
      alert('Failed to load cart items: ' + data.message);
    }
  } catch (error) {
    console.error('Error loading cart items:', error);
    alert('An unexpected error occurred while loading the cart.');
  }
}

async function addToCart(laptopId) {
  try {
    const response = await fetch('/add_to_cart', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ laptop_id: laptopId })
    });
    const data = await response.json();
    if (data.success) {
      alert(data.message);
      loadCartItems();
    } else {
      alert('Failed to add item to cart: ' + data.message);
    }
  } catch (error) {
    console.error('Error adding item to cart:', error);
    alert('An unexpected error occurred while adding the item to the cart.');
  }
}

document.addEventListener('DOMContentLoaded', loadCartItems);

async function submitOrder() {
  try {
    const totalPriceElement = document.getElementById('total-price');
    const totalAmount = parseFloat(totalPriceElement.innerText.replace('Total: ', '').replace(' Lei', ''));
    const response = await fetch('/submit_payment', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ total_amount: totalAmount })
    });
    const data = await response.json();
    if (data.success) {
      alert('Order submitted successfully!');
      window.location.href = '/catalog';
    } else {
      alert('Failed to submit order: ' + data.message);
    }
  } catch (error) {
    console.error('Error submitting order:', error);
    alert('An unexpected error occurred while submitting the order.');
  }
}

document.addEventListener('DOMContentLoaded', loadCartItems);