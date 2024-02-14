import React, { useEffect, useState } from 'react';
import { isMobile } from '../utils/responsive';
import { endpoints } from '../utils/api';

const InternshipOfferCard = ({
  internshipOffer,
  handleMouseOver,
  handleMouseOut,
  index,
  sendNotification,
  threeByRow
  }) => {

    const [isFavorite, setIsFavorite] = useState(internshipOffer.is_favorite);

    useEffect(() => {
    }, []);

    const addFavorite = (id) => {
    $.ajax({ type: 'POST', url: endpoints.addFavorite({id}), data: { id } })
        .done(fetchDone)
        .fail(fetchFail);
    };

    const removeFavorite = (id) => {
    $.ajax({ type: 'DELETE', url: endpoints.removeFavorite({id}), data: { id } })
        .done(fetchDone)
        .fail(fetchFail);
    };

    const fetchDone = (result) => {
      setIsFavorite(result['is_favorite']);
      sendNotification('Enregistré !');
      return true
    };

    const fetchFail = (xhr, textStatus) => {
      if (textStatus === 'abort') {
        return;
      }
    };

  return (
    <div className={`col-${isMobile() ? '12 text-align-center' : (threeByRow ? '4' : '6')} fr-my-2w ${isMobile() ? '' : ((index % 2) == 0) ? '' : 'fr-pr-0-5v'}`}
    key={internshipOffer.id}
    onMouseOver={(e) => handleMouseOver(internshipOffer.id)}
    onMouseOut={handleMouseOut}
    data-internship-offer-id={internshipOffer.id}
    >
      <div className="fr-card fr-enlarge-link" data-test-id={internshipOffer.id}>
        <div className="fr-card__body">
          <div className="fr-card__content">
            <h4 className="fr-card__title">
              <a href={internshipOffer.link} 
                className="row-link text-dark" 
                onClick={(e) => { e.stopPropagation() }}
              >
                {internshipOffer.title}
              </a>
            </h4>
            <div className="fr-card__detail">
              <div className="mr-auto">{internshipOffer.employer_name}</div>
              { internshipOffer.logged_in && internshipOffer.can_manage_favorite &&
                <div
                  className={`heart-${isFavorite ? 'full' : 'empty'}`}
                  onClick={(e) => {
                    if (isFavorite) {
                      removeFavorite(internshipOffer.id)
                    } else {
                      addFavorite(internshipOffer.id)
                    }
                  }
                  }
                ></div>
              }
            </div>
            <div className="fr-card__desc">
              <p className="blue-france">{ internshipOffer.city }</p>
              <div className="blue-france fr-text--bold my-2">
                Du {internshipOffer.date_start} au {internshipOffer.date_end}
              </div>
            </div>
          </div>
        </div>
        <div className="fr-card__header">
          <div className="fr-card__img">
            <img className="fr-responsive-img" src={internshipOffer.image} alt="secteur" />
          </div>
          <ul className="fr-badges-group">
            <li>
              <div className="fr-tag">{internshipOffer.sector}</div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default InternshipOfferCard;