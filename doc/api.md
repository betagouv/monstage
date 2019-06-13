Pour rendre les offres proposées par les associations / collectivités / ministères disponibles sur la plateforme Mon Stage de 3è, une API sera mise à disposition.

L'API sera construite sur le format REST, avec en ```baseUrl``` https://monstagedetroisieme.fr/api.

Les services web suivant seront mis à dispotion :

* POST /internship_offers : Pour ajouter une offre de stage sur Mon stage de 3e
* DELETE /internship_offers/{id} : Pour supprimer une offre de stage sur Mon stage de 3e

# Structure de donnée : Les offres de stages

```
{
  title : Titre de l’offre de stage
  description : Description de l'offre de stage

  employer_name : Nom de l’entreprise proposant le stage
  employer_description : Description de l’entreprise proposant le stage
  employer_website : Lien web vers le site de l’entreprise proposant le stage

  coordinates : Coordonnées géographique du lieu de stage
  street : Nom de la rue ou se déroule le stage
  zipcode  : Code postal ou se déroule le stage
  city : Nom de la ville où se déroule le stage

  sector_uuid : voir référentiel *(1)
  weeks : voir référentiel *(2)
}
```

*(1): [referenciel des secteurs](#ref-sectors)
*(2): [referenciel des semaines](#ref-weeks)


# Authentification

Les APIs sont ouvertes uniquement aux associations/opérateurs pouvant accèder à la plateforme via leurs comptes (faire la demande d'accès aux API à notre [support](mailto:martin.fourcade@beta.gouv.fr).

Une fois leurs comptes crées, les token d'API pourront être récupéré via notre interface web.

L'authentification se fait par token via :

* le header HTTP : ```Authorization: Bearer #{token} ```
* ou le header HTTP : ```HTTP_AUTHORIZATION: Bearer #{token} ```
* ou le param d'url token : ```token=Bearer #{token} ``` (**attention**, il faut tout encoder la valeur du paramêtre via le format d'url param ; donc Bearer en URL doit devenir Bearer+#{token}, un exemple est donnée plus tard...)


## Endpoint création d'offre.


**url** : https://monstagedetroisieme.fr/api/internship_offers

**method** : POST

**params** :

*(Contraintes de données)*

* **title** *(string, required)*
* **description** *(text, required *<= 715 caractères)
* **employer_name** *(string, required)*
* **employer_description** *(string, required *<= 275 caractères)
* **employer_website** *(string, optional)*
* **coordinates** *(object/geography, required)* : { latitude: 1, longitude: 1 }
* **street** *(text, optional)*
* **zipcode** *(string, required)*
* **city** *(string, required)*
* **sector_uuid** *(integer, required)*
* **weeks** (array[array(year, week_number), array(year, week_number), ...], optional) : si ce champs n'est pas remplis, le stage sera automatiquement disponible toute l'année

**exemple curl**

```
curl -H "Authorization: Bearer 68792260-2e41-40e4-a9e5-ec32ffa33ad8" \
     -H "Accept: application/json" \
     -H "Content-type: application/json" \
     -X POST \
     -d '{}' \
     -vvv \
     https://monstagedetroisieme.fr/api/internship_offers
```



### <a name="ref-weeks"></a>  
## Référentiel : Semaines
Les offres de stages se faisant par cycles hebdomadaires de travail (du lundi au vendredi), Cette information se matérialise par un "object" de “[semaine commerciale](https://fr.wikipedia.org/wiki/Num%C3%A9rotation_ISO_des_semaines)”, ex: 2019W35. Se definissant par un couple. C'est un "couple" composé de :

* L'année: 2019
* Le numéro de semaine: 1
* Joint par un W*(eek)*

Nous pouvons attendons donc ce couple dans nos API ; 
```
internship_offers.weeks: ["2019W1", "2019W3", "2019W5"]
```
### <a name="ref-sectors"></a>
## Référentiel : Secteurs d'activité

L'API attends en paramêtre obligatoire un secteur d'activité associé à une offre. Voici la *liste* ainsi que leurs **identifiants uniques**.

* *Mode*: **b7564ac4-e184-41c4-a7a9-57233a9d244a**
* *Banque et assurance*: **6a8f813b-c338-4d4f-a4cd-99a28748b57d**
* *Audiovisuel*: **4b6427b1-b289-486d-b7ea-f33134995a99**
* *Communication*: **63d73fd3-9ca6-4838-95aa-9901896be99c**
* *Édition, librairie, bibliothèque*: **27c1d368-0846-4038-903f-d63b989e0fe4**
* *Traduction, interprétation*: **1123edde-0d77-498a-85c5-2ab3d81b3cd8**
* Bâtiment et travaux publics
* *Comptabilité, gestion, ressources humaines*: **bfb24e1c-aebc-4451-bb4b-569ab71a814d**
* *Droit et justice*: **1711c7c8-89dc-48dd-9ae9-22bde1bd281b**
* *Enseignement*: **76f3a155-e592-4bb9-8512-358a7d9db313**
* *Recherche*: **c5db692a-2a17-403c-8151-1b3cd7dc48ba**
* *Énergie*: **af7e191a-7065-403e-844d-197e7e1e8bdb**
* *Environnement*: **1bbc6281-805e-4045-b85b-65a1479a865d**
* *Logistique et transport*: **19ccd244-5fac-4ad9-8513-7488d0980f4c**
* *Hôtellerie, restauration*: **92e5ad0c-6e30-43a4-8158-818236d01390**
* *Tourisme*: **dd9d626b-735a-4139-87b8-8c67990b97ba**
* *Agroéquipement*: **0b91687a-f3cc-4cd1-bfb5-b9f03994b1bd**
* *Automobile*: **f3733e9c-f33c-4c33-9903-baf9c8e2d2fb**
* *Construction aéronautique, ferroviaire et navale*: **ee0e9e5c-f19e-4be8-9399-2cff4f4e5ca5**
* *Électronique*: **1ce6aa62-6d91-41e5-9135-ce97e7c94a46**
* *Industrie alimentaire*: **95776212-ddd1-466e-ba5b-089f4e2f11ac**
* *Industrie chimique*: **4974df57-0111-492d-ab60-3bfdad10733d**
* *Maintenance*: **0f51b2d6-91da-4543-a0aa-d49a7be3d249**
* *Mécanique*: **4ee8bd54-7b5b-4ae9-9603-78f303d5aea8**
* *Verre, béton, céramique*: **463578f1-b371-4466-a13f-b0e99f783391**
* *Informatique et réseaux*: **bfd92448-5eae-4d99-ae2c-67fffc8fec69**
* *Jeu vidéo*: **be4bab4d-09ed-4205-bca1-1047da0500f8**
* *Commerce et distribution*: **ae267ff2-76d5-460a-9a41-3b820c392149**
* *Marketing, publicité*: **811621f0-e2d1-4c32-a406-5b45979d7c6d**
* *Médical*: **1aae3b41-1394-4109-83cf-17214e1aefdd**
* *Paramédical*: **89946839-8e18-4087-b48d-e6ee5f7d8480**
* *Social*: **d5a7ec0f-5f9c-44cb-add0-66465b4e7d3c**
* *Sport*: **01d06ada-55be-4ebf-8ad2-2666e7a7f521**
* *Agriculture*: **76de34d3-b524-456d-bc91-92e133cdab2b**
* *Filiere bois*: **aa658f28-a9ac-4a29-976f-a528c994f37a**
* *Architecture, urbanisme et paysage*: **1ee1b11c-97ca-4b7e-a6fb-afe404f24954**
* *Armée - Défense*: **4c0e0937-d7af-4b1c-998c-c1b1d628e3a3**
* *Sécurité*: **ec4ce411-f8fd-4690-b51f-3290ffd069e0**
* *Art et design*: **c1f72076-43fb-44ae-a811-d55eccf15c08**
* *Artisanat d'art*: **1ce60ecc-273d-4c73-9b1a-2f5ee14e1bc6**
* *Arts du spectacle*: **055b7580-c979-480f-a026-e94c8b8dc46e**
* *Culture et patrimoine*: **c76e6364-7257-473c-89aa-c951141810ce**


