// いまログインしているか（Cookie の合言葉が、いまも Rails で通るか）
export default defineEventHandler(async (event) => {
  return { loggedIn: await isValidAdminToken(event, getCookie(event, ADMIN_COOKIE)) }
})
