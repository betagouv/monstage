import React from 'react';

function RadioListSchoolInput({
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

  return (
    <div className={`form-group ${isWaitingCitySelection ? 'opacity-05' : ''}`}>
      {isWaitingCitySelection && (
        
        <div className="custom-label-container">
          <label className='fr-label' htmlFor={`${resourceName}_school_name`}>
            Collège
            <abbr title="(obligatoire)" aria-hidden="true">
              *
            </abbr>
          </label>
          <input
            value=""
            disabled
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
            <abbr title="(obligatoire)" aria-hidden="true">
              *
            </abbr>
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
          {(schoolsInCitySuggestions || []).map((school) => (
            <div className="fr-radio-group" key={`school-${school.id}`}>
              <input
                type="radio"
                id={`select-school-${school.id}`}
                name={`${resourceName}[school_id]`}
                value={school.id}
                checked={selectedSchool && selectedSchool.id == school.id}
                onChange={() => {
                  setSelectedSchool(school);
                  setClassRoomsSuggestions(school.class_rooms);
                }}
                required
                className="custom-control-input"
              />
              <label htmlFor={`select-school-${school.id}`} className="fr-label">
                {school.name}
              </label>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default RadioListSchoolInput;
