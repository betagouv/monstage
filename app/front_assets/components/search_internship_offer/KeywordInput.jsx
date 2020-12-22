import React, { useState, useEffect } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import focusedInput from './FocusedInput';
import { endpoints } from '../../utils/api';

const COMPONENT_FOCUS_LABEL = 'keyword';

function KeywordInput({ keyword, setKeyword, focus, setFocus }) {
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
        <div
          id="test-input-keyword-container"
          className={`input-group input-group-search col ${focusedInput({
            check: COMPONENT_FOCUS_LABEL,
            focus,
          })}`}
        >
          <div className="input-group-prepend">
            <label
              {...getLabelProps()}
              className="input-group-text input-group-search-left-border input-group-text-bigger"
              htmlFor="input-search-by-keyword"
            >
              <i className="fas fa-suitcase fa-fw" aria-hidden='true' />
              <strong className="d-none">Rechercher par Profession</strong>
            </label>
          </div>
          <input
            {...getInputProps({
              onChange: inputChange,
              value: inputValue,
              className: 'form-control pl-2',
              id: 'input-search-by-keyword',
              name: 'keyword',
              placeholder: 'Profession',
              'aria-label': 'Rechercher par Profession',
              onFocus: () => {
                setFocus(COMPONENT_FOCUS_LABEL);
              },
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
      )}
    </Downshift>
  );
}
export default KeywordInput;
