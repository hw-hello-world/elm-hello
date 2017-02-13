const Elm = require('./Main.elm');

export function bootstrap(config) {
  const app = Elm.Main.embed(document.getElementById('app-container'));

  app.ports.welcome.subscribe((msg) => {
    console.log("Hello Elm: ", msg);
  });

}

export default bootstrap;
