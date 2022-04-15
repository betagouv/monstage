import React, { useState, useEffect } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';

const COMPONENT_FOCUS_LABEL = 'keyword';

function KeywordInput({ existingKeyword, whiteBg }) {
  const searchParams = new URLSearchParams(window.location.search);

  const [keyword, setKeyword] = useState(existingKeyword || searchParams.get('keyword') || '');
  const [searchResults, setSearchResults] = useState([]);
  const [keywordDebounced] = useDebounce(keyword, 200);
  const inputChange = (event) => {
    setKeyword(event.target.value);
  };

  const safeSetKeyword = (item) => {
    if (item) {
      setKeyword(item.word);
    }
  };

  const searchKeyword = () => {
    fetch(endpoints.apiInternshipOfferKeywordsSearch({ keyword }), { method: 'POST' })
      .then((response) => response.json())
      .then(setSearchResults);
  };

  useEffect(() => {
    if (keywordDebounced && keywordDebounced.length > 2) {
      searchKeyword(keywordDebounced);
    }
  }, [keywordDebounced]);

  return (
    <Downshift
      initialInputValue={keyword}
      onChange={safeSetKeyword}
      selectedItem={keyword}
      itemToString={(item) => (item ? item.word : '')}
    >
      {({
        getInputProps,
        getItemProps,
        getLabelProps,
        getMenuProps,
        isOpen,
        inputValue,
        highlightedIndex,
        selectedItem,
      }) => (
        <div>
          <label {...getLabelProps({ className: `${(whiteBg == true) ? 'fr-label' : 'font-weight-lighter'}`, htmlFor: "input-search-by-keyword" })}>
            Métiers, mots-clés, ...
          </label>
          <div
            id="test-input-keyword-container"
            className={`input-group col p-0`}
          >
            <input
              {...getInputProps({
                onChange: inputChange,
                value: inputValue,
                className: 'fr-input almost-fitting',
                id: 'input-search-by-keyword',
                name: 'keyword',
                placeholder: '',
                'aria-label': 'Rechercher par Profession',
              })}
            />
            <div className="search-in-place bg-white shadow">
              <ul
                {...getMenuProps({
                  className: 'p-0 m-0',
                  'aria-labelledby': 'input-search-by-keyword',
                })}
              >
                {isOpen
                  ? searchResults.map((item, index) => (
                      <li
                        {...getItemProps({
                          className: `py-2 px-3 listview-item ${
                            highlightedIndex === index ? 'highlighted-listview-item' : ''
                          }`,
                          key: item.id,
                          index,
                          item,
                          style: {
                            fontWeight: selectedItem === item ? 'bold' : 'normal',
                          },
                        })}
                      >
                        {item.word}
                      </li>
                    ))
                  : null}
              </ul>
            </div>
          </div>
        </div>
      )}
    </Downshift>
  );
}
export default KeywordInput;
