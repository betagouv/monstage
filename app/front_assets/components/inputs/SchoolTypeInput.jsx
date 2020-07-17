import React, {useState} from 'react';


function SchoolTypeInput({schoolType, setSchoolType}) {
  const [filterByTypeEnabled, setfilterByTypeEnabled] = useState(schoolType !== null)
  const isOptionShown = schoolType != null || filterByTypeEnabled

  const onTogglefilterByTypeEnabled = (event) => {
    setfilterByTypeEnabled(event.target.checked);
    if (!event.target.checked) {
      setSchoolType(null)
    }
  }

  return (
    <div className="form-group form-check form-check-inline p-0 m-0">
      <div class="custom-control custom-checkbox">
        <input id="toggle-choose-school-type"
               className="custom-control-input"
               type="checkbox"
               checked={isOptionShown}
               onChange={onTogglefilterByTypeEnabled}
               />
        <label className="custom-control-label mr-3" htmlFor='toggle-choose-school-type'>
          {" Filtrer par niveau scolaire"}
        </label>
      </div>
      <div className={`custom-control custom-radio custom-control-inline ${isOptionShown ? '' : 'd-none'}`}>
          <input
            type="radio"
            name="school_type"
            checked={schoolType === 'middle_school'}
            value="middle_school"
            onChange={(event) => setSchoolType(event.target.value)}
            className="custom-control-input"
            id="search-by-middle-school"
          />
        <label className="custom-control-label" htmlFor="search-by-middle-school">
            Collège
        </label>
      </div>
      <div className={`custom-control custom-radio custom-control-inline ${isOptionShown ? '' : 'd-none'}`}>
        <input
          type="radio"
          name="school_type"
          value="high_school"
          checked={schoolType === 'high_school'}
          onChange={(event) => setSchoolType(event.target.value)}
          className="custom-control-input"
          id="search-by-high-school"
        />
        <label className="custom-control-label" htmlFor="search-by-high-school">
          Lycée
        </label>
      </div>
    </div>
  );
}
export default SchoolTypeInput;
