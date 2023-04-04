def populate_operators
  Operator.create(name: "Un stage et après !",
                  website: "",
                  logo: 'Logo-un-stage-et-apres.jpg',
                  target_count: 120)
  # this one is for test
  Operator.create(name: "JobIRL",
                  website: "",
                  logo: 'Logo-jobirl.jpg',
                  target_count: 32)
  Operator.create(name: "Le Réseau",
                  website: "",
                  logo: 'Logo-le-reseau.jpg',
                  target_count: 710)
  Operator.create(name: "Institut Télémaque",
                  website: "",
                  logo: 'Logo-telemaque.png',
                  target_count: 1200)
  Operator.create(name: "Myfuture",
                  website: "",
                  logo: 'Logo-moidans10ans.png',
                  target_count: 1200)
  Operator.create(name: "Les entreprises pour la cité (LEPC)",
                  website: "",
                  logo: 'Logo-les-entreprises-pour-la-cite.jpg',
                  target_count: 1200)
  Operator.create(name: "Tous en stage",
                  website: "",
                  logo: 'Logo-tous-en-stage.jpg',
                  target_count: 1200)
  Operator.create(name: "Viens voir mon taf",
                  website: "",
                  logo: 'Logo-viens-voir-mon-taf.jpg',
                  target_count: 1200)
end

call_method_with_metrics_tracking([:populate_operators])