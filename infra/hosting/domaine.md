# 2eme version, monstage

En préambule il faut savoir que le code est hébergé par Heroku ([lien](http://heroku.com/)).

Cette plateforme expose les applications hébergées via des CNAMEs.

Nous y hébergons deux environnements :

* un de test (qui monte de version ± tous les jours),
* un destiné a devenir la production (qui monte de version ± toutes les deux semaines).

## Environnement de test

Actuellement accessible via : [https://v2-test.monstagedetroisieme.fr](https://v2-test.monstagedetroisieme.fr)

Pour la configuration du CNAME, pouvez-vous faire pointer **v2-test.monstagedetroisieme.fr** sur **darwinian-orca-0cqovj7wszaz94zaelrzhewe.herokudns.com.** (attention le point a la fin est important)

Exemple d'entrée DNS :

```
v2-test                      IN CNAME  darwinian-orca-0cqovj7wszaz94zaelrzhewe.herokudns.com.
```


## Domaine de production

Actuellement notre application de production est accessible via : [v2.monstagedetroisieme.fr](v2.monstagedetroisieme.fr)

Pour la configuration du CNAME, pouvez-vous faire pointer **v2.monstagedetroisieme.fr** sur **elementary-watercress-nq42aaszcz812tznsspynlfk.herokudns.com.** (attention le point a la fin est important)


Exemple d'entrée DNS :

```
www                      IN CNAME elementary-watercress-nq42aaszcz812tznsspynlfk.herokudns.com.
```

