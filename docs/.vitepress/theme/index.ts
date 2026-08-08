import { h } from 'vue'
import DefaultTheme from 'vitepress/theme'
import BuyMeACoffeeButton from './BuyMeACoffeeButton.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'nav-bar-content-after': () => h(BuyMeACoffeeButton),
      'nav-screen-content-after': () => h(BuyMeACoffeeButton),
    })
  },
}
