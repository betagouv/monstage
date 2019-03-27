# 2eme version, monstage

En préambule il faut savoir que le code est hébergé par Heroku ([lien](http://heroku.com/)).

Cette plateforme expose les applications hébergées via des CNAMEs.

Nous y hébergons deux environnements :

* un de test (qui monte de version ± tous les jours),
* un destiné a devenir la production (qui monte de version ± toutes les deux semaines).

## Environnement de test

Actuellement accessible via : [https://betagouv-monstage-staging.herokuapp.com](https://betagouv-monstage-staging.herokuapp.com)

Nous souhaitons l'exposer sur : **https://v2-test.monstagedetroisieme.fr**


Pour la configuration du CNAME, pouvez-vous faire pointer **v2-test.monstagedetroisieme.fr** sur **darwinian-orca-0cqovj7wszaz94zaelrzhewe.herokudns.com.** (attention le point a la fin est important)

Exemple d'entrée DNS :

```
v2-test                      IN CNAME  darwinian-orca-0cqovj7wszaz94zaelrzhewe.herokudns.com.
```


## Domaine de production

Actuellement notre application de production est accessible via : [https://betagouv-monstage-prod.herokuapp.com](https://betagouv-monstage-prod.herokuapp.com)

Cette application n'est pas encore prête a être lachée dans la nature (moche). Nous souhaitons donc l'exposer temporairement sur : **https://v2.monstagedetroisieme.fr**.

A terme, nous utiliserons **https://monstagedetroisieme.fr** (avec le https://www.monstagedetroisieme.fr en redirection permanente sur https://monstagedetroisieme.fr). Nous reviendrons vers vous une fois l'application prête.

Pour la configuration du CNAME, pouvez-vous faire pointer **v2.monstagedetroisieme.fr** sur **elementary-watercress-nq42aaszcz812tznsspynlfk.herokudns.com.** (attention le point a la fin est important)


Exemple d'entrée DNS :

```
v2                      IN CNAME elementary-watercress-nq42aaszcz812tznsspynlfk.herokudns.com.
```

