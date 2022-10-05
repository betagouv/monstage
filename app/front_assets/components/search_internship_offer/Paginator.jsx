import React from 'react';

function Paginator({ paginateLinks }) {
  function pageUrl(pageId) {
    return paginateLinks.pageUrlBase + '&page=' + pageId
  };

  return (
  <div className='fr-mt-1w'>
    <nav role="navigation" className="fr-pagination" aria-label="Pagination">
      <ul className="fr-pagination__list d-flex justify-content-center">
        { paginateLinks ? (
            paginateLinks.isFirstPage ? '' : (
              <li>
                <a href={pageUrl(paginateLinks.prevPage)} className="fr-pagination__link fr-pagination__link--prev fr-pagination__link--lg-label" aria-disabled="false" role="link">
                  Page précédente
                </a>
              </li>
              
            )
          ) : ''
        }

        {/* PREVIOUS PAGE */}
        { 
          paginateLinks.isFirstPage ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.prevPage)} className="fr-pagination__link fr-displayed-lg"  title={`Page ${paginateLinks.prevPage}`}>
                {paginateLinks.prevPage}
              </a>
            </li>
          )
        }

        {/* CURRENT PAGE */}
        <li>
          <a className="fr-pagination__link" aria-current="page" title={`Page ${paginateLinks.currentPage}`}>
            {paginateLinks.currentPage}
          </a>
        </li>

        {/* NEXT PAGE */}
        { 
          paginateLinks.isLastPage ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.nextPage)} className="fr-pagination__link fr-displayed-lg" title={`Page ${paginateLinks.nextPage}`}>
                {paginateLinks.nextPage}
              </a>
            </li>
          )
        }

        { 
          paginateLinks.isLastPage ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.nextPage)} className="fr-pagination__link fr-pagination__link--next fr-pagination__link--lg-label">
                Page suivante
              </a>
            </li>
          )
        }
      </ul>
    </nav>
  </div>
  )
};

export default Paginator;