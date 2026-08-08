<template>
  <a
    :href="buyMeACoffeeUrl"
    target="_blank"
    rel="noreferrer"
    class="bmc-link"
  >
    <img
      :src="buyMeACoffeeButtonUrl"
      alt="Buy me a coffee"
      class="bmc-button"
    />
  </a>
</template>

<script setup lang="ts">
const buyMeACoffeeUrl = 'https://buymeacoffee.com/lidhincs'
const buyMeACoffeeButtonUrl =
  'https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png'
</script>

<style scoped>
.bmc-link {
  display: inline-flex;
  align-items: center;
  margin-left: 12px;
  line-height: 0;
}

.bmc-button {
  height: 28px;
  width: auto;
}

@media (max-width: 768px) {
  .bmc-link {
    margin-left: 0;
    margin-top: 12px;
  }

  .bmc-button {
    height: 32px;
  }
}
</style>
