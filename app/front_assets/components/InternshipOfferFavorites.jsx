import React, { useEffect, useState } from 'react';

import InternshipOfferCard from './InternshipOfferCard';
import { isMobile, isTablet } from '../utils/responsive';
import FlashMessage from './FlashMessage';


const InternshipOfferFavorites = ({ internshipOffers }) => {
  const [notify, setNotify] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState('');


  useEffect(() => {

  }, []);

  const handleMouseOver = (data) => {
  };

  const handleMouseOut = () => {
  };

  const sendNotification = (message) => {
    setNotify(true);
    setNotificationMessage(message);
  };

  const hideNotification = () => {
    setNotify(false);
  };

  return (
    <>
      {notify ? (
        <div className="results-container">
          <FlashMessage
            message={notificationMessage}
            display={notify}
            hideNotification={hideNotification}
          />
        </div>
      ) : ''}
      {/* Cards */}
      { internshipOffers.length == 0 ?
        (<div className="row mx-0 fr-px-2w fr-mt-2w">
            <div className='col-12'>
              <h2 className='h3'>Vous n'avez aucune annonce sauvegardée.</h2>
              <p className="fr-py-1w">Pour en ajouter une, effectuez une recherche et cliquez sur le coeur pour enregistrer l'annonce qui vous intéresse.</p>
              <a class="fr-btn fr-raw-link fr-px-8w" href="/offres-de-stage">Trouver un stage </a>
            </div>
        </div>
        ) :
        (<div className="results-container">
          <div className="row mx-0 fr-px-2w fr-mt-2w">
              {
                internshipOffers.map((internshipOffer, i) => (
                  <InternshipOfferCard
                    internshipOffer={internshipOffer}
                    key={internshipOffer.id}
                    index={i}
                    handleMouseOut={handleMouseOut}
                    handleMouseOver={(value) => { handleMouseOver(value) }}
                    sendNotification={(message) => { sendNotification(message) }}
                    threeByRow={!isTablet()}
                    can_manage_favorite = {internshipOffer.can_manage_favorite}
                  />
                ))
              }
          </div>
        </div>)
      }
    </>
  );
};

export default InternshipOfferFavorites;