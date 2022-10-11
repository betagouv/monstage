import React, { useEffect, useState } from 'react';
import { isMobile } from '../utils/responsive';

const InternshipOfferCard = ({ internshipOffer, handleMouseOver, handleMouseOut, index }) => {
  useEffect(() => {
  }, []);

  return (
    <div className={`col-${isMobile() ? '12 text-align-center' : '6'} fr-my-2w ${isMobile() ? '' : ((index % 2) == 0) ? 'fr-pl-0-5v' : 'fr-pr-0-5v'}`}
    key={internshipOffer.id}
    onMouseOver={(e) => handleMouseOver(internshipOffer.id)}
    onMouseOut={handleMouseOut}
    data-internship-offer-id={internshipOffer.id}
    >
      <div className="fr-card fr-enlarge-link" data-test-id={internshipOffer.id}>
        <div className="fr-card__body">
          <div className="fr-card__content">
            <h4 className="fr-card__title">
              <a href={internshipOffer.link} className="row-link text-dark">{ internshipOffer.title }</a>
            </h4>
            <p className="fr-card__detail">{ internshipOffer.employer_name }</p>
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
  )
};

export default InternshipOfferCard;