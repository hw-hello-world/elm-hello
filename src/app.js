const Elm = require('./T.elm');

export function bootstrap(config) {
  const app = Elm.Main.embed(document.getElementById('app-container'), {elapsed: 1000});

  var start = new Date().getTime();

  function update() {
    const container = document.getElementById('app-container');
    const inits = {
      elapsed: new Date().getTime() - start,
    };

    const app = Elm.Main.embed(container, inits);

    requestAnimationFrame(update);
  }
  //requestAnimationFrame(update);

  //app.ports.welcome.subscribe((msg) => {
  //  console.log("Hello Elm: ", msg);
  //});

}

export default bootstrap;
