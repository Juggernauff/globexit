const searchInput = document.querySelector('.search-input')
searchInput.addEventListener('input', searchUser)

const userCardContainer = document.querySelector('.user-card-container')
userCardContainer.addEventListener('click', openUserCard)

popupUserCard = document.querySelector('.popup-user-card')
popupClosingIcon = document.querySelector('.popup-user-card-info-element-header img')

window.addEventListener('keydown', (event) => {
  if (event.key === "Escape") {
    closeUserCard(event)
  }
})

let USERS = []
getUsers()


function editUserCard(user) {
  popupUserCard.innerHTML = `
  <div class="popup-user-card-body">
  <div
  class="popup-user-card-info-element-header">
    <h2
    class="popup-user-card-info-element-header-text">
      ${user.name}
    </h2>
    <img src="images/icons/close.svg"
         onclick="closeUserCard();"/>
  </div>
  <div class="popup-user-card-info-element-body">
    <div
    class="popup-user-card-info-element-body-keys
           popup-user-card-info-element-body-text-key">
      <text>Телефон:</text>
      <text>Почта:</text>
      <text>Дата приема:</text>
      <text>Должность:</text>
      <text>Подразделение:</text>
    </div>
    <div
    class="popup-user-card-info-element-body-values
           popup-user-card-info-element-body-text-value">
      <text>${user.phone}</text>
      <text>${user.email}</text>
      <text>${user.hire_date}</text>
      <text>${user.position_name}</text>
      <text>${user.department}</text>
    </div>
  </div>
  <div
  class="popup-user-card-info-element-footer">
    <text
    class="popup-user-card-info-element-footer-text-title">
      Дополнительная информация:
    </text>
    <text
    class="popup-user-card-info-element-footer-text-value">
      Разработчики используют текст в качестве заполнителя макта страницы. Разработчики используют текст в качестве заполнителя макта страницы.
    </text>
  </div>
</div>
  `

  return popupUserCard
}

function openUserCard(event) {
  if (event.target.dataset.index === undefined) return;

  const index = parseInt(event.target.dataset.index)
  const fullName = event.target.querySelector('#fullName').textContent
  const phoneNumber = event.target.querySelector('.user-card-info-element #phoneNumber').textContent
  const email = event.target.querySelector('.user-card-info-element #email').textContent

  const user = USERS.find((user) => (
    user.name === fullName
    && user.email === email
    && user.phone === phoneNumber
  ))

  if (user === undefined) return;
  
  const userCard = editUserCard(user)
  userCard.classList.add('open')
}

function closeUserCard() {
  popupUserCard.classList.remove('open')
}

function searchUser(event) {
  const filterValue = event.target.value.toLowerCase()
  const filteredUsers = USERS.filter((user) => {
    return user.name.toLowerCase().includes(filterValue)
  })
  render(filteredUsers)
}

async function getUsers() {
  try {
    const response = await fetch(`http://localhost:3000`)
    const data = await response.json()
    
    USERS = data
    render(USERS)
  } catch(error) {
    alert(`Ошибка 500. Не удалось подключиться к серверу.`)
    console.log(error.message)
  }
}

function toHTML(user, index) {
  return `
  <div data-index="${index}" class="user-card">
    <h2 id="fullName">${user.name}</h2>
    <div class="user-card-info-element">
      <img src="images/icons/phone.svg" />
      <text id="phoneNumber">${user.phone}</text>
    </div>
    <div class="user-card-info-element">
      <img src="images/icons/email.svg" />
      <text id="email">${user.email}</text>
    </div>
  </div>
  `
}

function render(users = []) {
  const html = users.map((user, index) => toHTML(user, index)).join('')
  userCardContainer.innerHTML = html
}