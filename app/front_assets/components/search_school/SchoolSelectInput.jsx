import React from 'react';

function RenderSchoolSelectInput({
  setClassRoomsSuggestions,
  setSelectedSchool,
  selectedSchool,
  schoolsInCitySuggestions,
  existingSchool,
  resourceName,
  classes,
}) {
  const isWaitingCitySelection =
    schoolsInCitySuggestions.length === 0 && !selectedSchool && !existingSchool;
  const isAlreadySelected = schoolsInCitySuggestions.length === 0 && existingSchool;
  const hasPendingSuggestion = schoolsInCitySuggestions.length > 0;

  const renderSchoolOption = (school) => (
    <option
      key={`school-${school.id}`}
      value={school.id}
      selected={selectedSchool && selectedSchool.id === school.id}
    >
      {school.name}
    </option>
  );

  const selectSchool = (school_id) => {
    const school = schoolsInCitySuggestions.filter(obj => {
      return obj.id == school_id })[0];
    setSelectedSchool(school);
    setClassRoomsSuggestions(school.class_rooms);
  };

  return (
    <div className={`form-group ${isWaitingCitySelection ? 'opacity-05' : ''}`}>
      {isWaitingCitySelection && (
        <div className="custom-label-container fr-mt-2w">
          <label className='fr-label' htmlFor={`${resourceName}_school_name`}>
            Collège
          </label>
          <input
            value=""
            disabled
            placeholder="Sélectionnez une option"
            className={`form-control ${classes || ''}`}
            type="text"
            id={`${resourceName}_school_name`}
          />
        </div>
      )}
      {isAlreadySelected && (
        <div className="custom-label-container">
          <label className='fr-label' htmlFor={`${resourceName}_school_name`}>
            Collège
          </label>
          <input
            readOnly
            disabled
            className={`fr-input ${classes || ''}`}
            type="text"
            value={existingSchool.name}
            name={`${resourceName}[school_name]`}
            id={`${resourceName}_school_name`}
          />
          
          <input type="hidden" value={existingSchool.id} name={`${resourceName}[school_id]`} />
        </div>
      )}
      {hasPendingSuggestion && (
        <div>
          <label htmlFor={`${resourceName}_school_id`} className="fr-label">Collège</label>
          
           
              <select
                id={`${resourceName}_school_id`}
                name={`${resourceName}[school_id]`}
                onChange={(e) => {
                  selectSchool(e.target.value);
                }}
                required
                className="fr-select"
              >
                {!selectedSchool && (
                  <option key="school-null" selected disabled>
                    -- Veuillez choisir un collège --
                  </option>
                )}

                {(schoolsInCitySuggestions || []).map(renderSchoolOption)}
              </select>
              
          
        </div>
      )}
    </div>
  );
}

export default RenderSchoolSelectInput;
