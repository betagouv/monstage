import React, { useEffect, useState } from 'react';
import { isMobile } from '../utils/responsive';


const FlashMessage = ({
  message,
  display,
  hideNotification
  }) => {
    useEffect(() => {
    }, [message]);

  return (
    <div>
      { display ? (
        <div id="alert-success" className="alert alert-sticky alert-success col-12 show mt-5" role="alert" data-flash-target="root">
        
          <div className="row align-items-center no-gutters container-alert-content">
          <div className=" col-1 col-sm-auto text-center mr-2">
          <i className="fas fa-2x mr-3 fa-check"></i>
          </div>
          <div className="col">
          <span id="alert-text">{message}</span>
          </div>
          
          <button type="button" className="close-notification alert-link" onClick={hideNotification}>
            Fermer <span aria-hidden="true">×</span>
          </button>
          </div>
        </div> 
      ) : '' }
    </div>
  );
};

export default FlashMessage;