import React, { useEffect, useState } from 'react';
import { isMobile } from '../utils/responsive';
import { endpoints } from '../utils/api';

const InternshipOfferFavoriteButton = ({
  internshipOffer,
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
      return true
    };

    const fetchFail = (xhr, textStatus) => {
      if (textStatus === 'abort') {
        return;
      }
    };

  return (
    <div>
      { (internshipOffer.isDisabled) ? (
        <div className='heart-disabled'></div>
      ) : (
        <div
          className={`heart-${isFavorite ? 'full' : 'empty'}`}
          onClick={(e) => {
            if (isFavorite) {
              removeFavorite(internshipOffer.id)
            } else {
              addFavorite(internshipOffer.id)
            }
          }}
        ></div>
      )}
    </div>
  );
};

export default InternshipOfferFavoriteButton;