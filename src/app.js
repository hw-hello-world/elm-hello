const Elm = require('./Main.elm');

export function bootstrap(config) {
  const app = Elm.Main.embed(document.getElementById('app-container'), {
    user: typeof config.user !== 'undefined' ? config.user : null,
  });

  app.ports.welcome.subscribe(() => {
    console.log("Hello Elm");
  });

}

export default bootstrap;
