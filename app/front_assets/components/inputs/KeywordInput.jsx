import React, { useState, useEffect } from 'react';
import Downshift from 'downshift';
import focusedInput from './FocusedInput';

const COMPONENT_FOCUS_LABEL = 'keyword';

function KeywordInput({ keyword, setKeyword, focus, setFocus }) {
  const [searchResults, setSearchResults] = useState([]);

  const inputChange = event => {
    setKeyword(event.target.value);
  };

  const safeSetKeyword = item => {
    if (item) {
      setKeyword(item.word);
    }
  }

  const searchKeyword = () => {
    const endpoint = new URL(
      `${document.location.protocol}//${document.location.host}/internship_offer_keywords/search`,
    );
    const searchParams = new URLSearchParams();

    searchParams.append('keyword', keyword);
    endpoint.search = searchParams.toString();

    fetch(endpoint, { method: 'POST' })
      .then(response => response.json())
      .then(setSearchResults);
  };

  useEffect(() => {
    if (keyword && keyword.length > 0) {
      searchKeyword(keyword);
    }
  }, [keyword]);

  return (
    <Downshift
      initialInputValue={keyword}
      onChange={safeSetKeyword}
      selectedItem={keyword}
      itemToString={item => (item ? item.word : '')}
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
          id='test-input-keyword-container'
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
              <i className="fas fa-suitcase fa-fw" />
              <strong className="d-none">Mot clé</strong>
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
              onFocus: () => {
                setFocus(COMPONENT_FOCUS_LABEL);
              },
            })}
          />
          <div className="search-in-place bg-white shadow">
            <ul
              {...getMenuProps({
                className: 'p-0 m-0',
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
