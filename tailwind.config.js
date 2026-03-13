/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'lm-gold': '#C59F00',
        'lm-green': '#396422',
        'lm-gray': '#4B4646',
      },
    },
  },
  plugins: [],
}
