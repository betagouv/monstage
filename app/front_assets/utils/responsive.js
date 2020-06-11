function findBootstrapEnvironment() {
  let envs = ['xs', 'sm', 'md', 'lg', 'xl'];
  let el = document.createElement('div');
  document.body.appendChild(el);

  let curEnv = envs.shift();

  for (let env of envs.reverse()) {
      el.classList.add(`d-${env}-none`);

      if (window.getComputedStyle(el).display === 'none') {
          curEnv = env;
          break;
      }
  }

  document.body.removeChild(el);
  return curEnv;
}
export default findBootstrapEnvironment;
