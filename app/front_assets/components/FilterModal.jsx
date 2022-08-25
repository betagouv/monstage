import React from "react";

const FilterModal = ({ sectors, requestInternshipOffers, clearSectors }) => (
  <dialog aria-labelledby="fr-modal-title-modal-filter" role="dialog" id="fr-modal-filter" className="fr-modal modal-filter">
  <div className="fr-container fr-container--fluid fr-container-md">
    <div className="fr-grid-row fr-grid-row--center">
      <div className="fr-col-12 fr-col-md-8 fr-col-lg-6">
        <div className="fr-modal__body">
          <div className="fr-modal__header modal-section">
            <div className="row d-flex align-items-center">
                <div
                  className="text-center fr-text--bold"
                  style={{ margin: '4px auto 0 auto', width: 200 + 'px' }}
                >
                Tous les filtres
              </div>
              <div className="float-right text-right" style={{float: 'right'}}>
                <button className="fr-btn--close fr-btn" title="Fermer la fenêtre modale" aria-controls="fr-modal-filter">Fermer</button>
              </div>
            </div>
          </div>

          <form onSubmit={ e => {
            e.preventDefault();
            requestInternshipOffers();
          }}
          >
            <div className="fr-modal__content modal-section">
              <h1 id="fr-modal-title-modal-1" className="fr-modal__title fr-mt-2w">Secteurs d'activité</h1>
              <div className="row">
                {
                  sectors.map((sector, index) => (
                    <div className='fr-checkbox-group col-6 fr-checkbox-group--sm' key={sector.id}>
                      <input type="checkbox" id={`checkbox-${index+1}`} name={`checkbox-${index+1}`} data-sector-id={sector.id} className="checkbox-sector"/>
                      <label className="fr-label muted" htmlFor={`checkbox-${index+1}`}>{ sector.name }</label>
                    </div>
                  ))
                }
              </div> 
            </div>

            <div className="fr-modal__footer">
              <div className="row">
                <div className="col-4 text-left align-self-center clear-button" onClick={clearSectors}>
                  Tout effacer
                </div>

                <div className="col-8 text-right align-self-center">
                  <button className="fr-btn" >
                    Appliquer ces filtres
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</dialog>
)

export default FilterModal