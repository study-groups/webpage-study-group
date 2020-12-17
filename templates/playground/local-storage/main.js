const storageInput = document.querySelector('.item-storage');
const item = document.querySelector('.item');
const quantity = document.querySelector('.quantity');
const button = document.querySelector('.button');
const data = [];
const dataRecord = 


storageInput.addEventListener('input', letter => {
  console.log(letter.target.value)
  item.textContent = letter.target.value
})

const saveToLocalStorage = () => {
  localStorage.setItem('textInput', item.textContent),
  localStorage.setItem('textInput', quantity.textContent)
}

button.addEventListener('click', saveToLocalStorage)

// To test, open dev tools, click on right double arrows (>>), in drop down menu
// select Application, then select localStorage
