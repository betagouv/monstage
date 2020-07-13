import React from 'react';


function SchoolTypeInput({middleSchool, toggleMiddleSchool, highSchool, toggleHighSchool, schoolTypeVisibility}) {

  const visibility = (schoolTypeVisibility == null) ? true : schoolTypeVisibility
  const schoolTypeClass = "text-muted pl-5 form-inline"
  const visibilityClass = (visibility) ? schoolTypeClass : schoolTypeClass + " d-none"

  return (
    <span id="schoolType" className={visibilityClass} style={{fontWeight: 'lighter'}} >
      Afficher les offres de :
      <div id="middleSchoolType " className="checkBox pl-3">
        <label>
          <input
            type="checkbox"
            name="middle_school"
            checked={middleSchool}
            onChange={toggleMiddleSchool}
            className="mr-1"
          />Collège
        </label>
      </div>
      <div id="highSchoolType " className="checkBox pl-3">
        <label>
          <input
            type="checkbox"
            name="high_school"
            checked={highSchool}
            onChange={toggleHighSchool}
            className="mr-1"
          />Lycée
        </label>
      </div>
    </span>
  );
}
export default SchoolTypeInput;