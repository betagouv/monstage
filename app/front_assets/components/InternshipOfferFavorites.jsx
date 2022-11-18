import React, { useEffect, useState } from 'react';

import InternshipOfferCard from './InternshipOfferCard';
import CardLoader from './CardLoader';
import TitleLoader from './TitleLoader';
import { endpoints } from '../utils/api';
import { isMobile } from '../utils/responsive';
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
    <div className="results-container">
      { notify ? (
        <FlashMessage 
          message={notificationMessage}
          display={notify}
          hideNotification={hideNotification} 
        />
      ) : '' }
      <div className="row mx-0 fr-px-2w">
        <div className={`${isMobile() ? 'col-12 px-0' : 'col-12 px-3'} d-flex`}>

          <div className="fr-mt-2w">
            <div className="row"> {/* Cards */}
              { internshipOffers.length == 0 ? 
                (
                  <div className='col-12'>
                    <h1>Vous n'avez aucune annonce sauvegardée.</h1>
                    <p className="fr-py-1w">Pour en ajouter une, effectuez une recherche et cliquez sur le coeur pour enregistrer l'annonce qui vous intéresse.</p>
                    <a class="fr-btn fr-raw-link fr-px-8w" href="/">Trouver un stage </a>
                  </div>
                ) : 
                (
                  internshipOffers.map((internshipOffer, i) => (
                    <InternshipOfferCard
                      internshipOffer={internshipOffer}
                      key={internshipOffer.id}
                      index={i}
                      handleMouseOut={handleMouseOut}
                      handleMouseOver={(value) => {handleMouseOver(value)}}
                      sendNotification={(message) => {sendNotification(message)}}
                      threeByRow
                      />
                  ))
                )
              }  
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default InternshipOfferFavorites;