const storageInput = document.querySelector('.storage');
const text = document.querySelector('.text');
const button = document.querySelector('.button');

storageInput.addEventListener('input', letter => {
  console.log(letter.target.value)
  text.textContent = letter.target.value
})

const saveToLocalStorage = () => {
  localStorage.setItem('textInput', text.textContent)
}

button.addEventListener('click', saveToLocalStorage)

// To test, open dev tools, click on right double arrows (>>), in drop down menu
// select Application, then select localStorage
