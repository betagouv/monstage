import React from 'react';

const TRADS = {
  troisieme_generale: '3e',
  troisieme_prepa_metier: '3e prépa-métiers',
  troisieme_segpa: 'Segpa',
};
function RenderClassRoomsInput({
  selectedClassRoom,
  classRoomsSuggestions,
  resourceName,
  existingClassRoom,
  classes,
}) {
  const isWaitingSchoolSelection =
    classRoomsSuggestions === null && !selectedClassRoom && !existingClassRoom;
  const isAlreadySelected = classRoomsSuggestions === null && existingClassRoom;
  const hasPendingSuggestion = classRoomsSuggestions && classRoomsSuggestions.length > 0;

  const renderClassRoomOption = (classRoom) => (
    <option
      key={`class-room-${classRoom.id}`}
      value={classRoom.id}
      selected={selectedClassRoom && selectedClassRoom.id === classRoom.id}
    >
      {classRoom.name}
    </option>
  );

  const classRoomsSuggestionsByType = (classRoomsSuggestions || []).reduce((accu, item) => {
    if (!accu[item.school_track]) {
      accu[item.school_track] = [];
    }
    accu[item.school_track].push(item);
    accu[item.school_track].sort((a, b) => {
      if (a.name < b.name) {
        return -1;
      }
      if (a.name > b.name) {
        return 1;
      }
      return 0;
    });
    return accu;
  }, {});

  return (
    <div
      className={`form-group custom-label-container ${
        isWaitingSchoolSelection ? 'opacity-05' : ''
      }`}
    >
      {isWaitingSchoolSelection && (
        <>
          <input
            value=""
            disabled
            className={`form-control ${classes || ''}`}
            type="text"
            id={`${resourceName}_class_room_id`}
          />
          <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
        </>
      )}
      {isAlreadySelected && (
        <>
          <input
            disabled
            readOnly
            className={`form-control ${classes || ''}`}
            type="text"
            value={existingClassRoom.name}
            name={`${resourceName}[class_room_name]`}
            id={`${resourceName}_class_room_name`}
          />
          <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          <input
            value={existingClassRoom.id}
            type="hidden"
            name={`${resourceName}[class_room_id]`}
          />
        </>
      )}
      {hasPendingSuggestion && (
        <>
          <select
            className="form-control"
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
          >
            {!selectedClassRoom && (
              <option key="class-room-null" selected disabled>
                -- Veuillez choisir une classe --
              </option>
            )}
            {Object.keys(classRoomsSuggestionsByType).length > 1 &&
              Object.keys(classRoomsSuggestionsByType).map((schoolTrack) => (
                <optgroup label={TRADS[schoolTrack]}>
                  {classRoomsSuggestionsByType[schoolTrack].map(renderClassRoomOption)}
                </optgroup>
              ))}

            {Object.keys(classRoomsSuggestionsByType).length <= 1 &&
              (classRoomsSuggestions || []).map(renderClassRoomOption)}
            <option value="">Autre classe</option>
          </select>
          <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
        </>
      )}
      {classRoomsSuggestions && classRoomsSuggestions.length === 0 && (
        <>
          <input
            placeholder="Aucune classe disponible"
            readOnly
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
            value=""
            className={`form-control ${classes || ''}`}
            type="text"
          />
          <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
        </>
      )}
    </div>
  );
}

export default RenderClassRoomsInput;
