module.exports = {
  presets: [require("../deps/moon/assets/tailwind.config.js")],
  content: [
    "../lib/**/*.ex",
    "../lib/**/*.heex",
    "../lib/**/*.eex",
    "./js/**/*.js",
    "../lib/**/pages/*.sface",
    "../lib/**/live/*.sface",
    "../lib/**/pages/*.ex",

    "../deps/moon/lib/**/*.ex",
    "../deps/moon/lib/**/*.heex",
    "../deps/moon/lib/**/*.eex",
    "../deps/moon/assets/js/**/*.js",
  ],
  theme: {
    fontFamily: {
      kanit:  ['Kanit', 'serif']
    },
  }
};