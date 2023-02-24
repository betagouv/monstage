import React from 'react';

const TRADS = {
  troisieme_generale: '3e',
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

  return (
    <div
      className={`form-group custom-label-container ${
        isWaitingSchoolSelection ? 'opacity-05' : ''
      }`}
    >
      {isWaitingSchoolSelection && (
        <>
          <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          <input
            value=""
            disabled
            className={`fr-input ${classes || ''}`}
            type="text"
            id={`${resourceName}_class_room_id`}
          />
        </>
      )}
      {isAlreadySelected && (
        <>
           <label className='fr-label' htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          <input
            disabled
            readOnly
            className={`fr-input ${classes || ''}`}
            type="text"
            value={existingClassRoom.name}
            name={`${resourceName}[class_room_name]`}
            id={`${resourceName}_class_room_name`}
          />
          <input
            value={existingClassRoom.id}
            type="hidden"
            name={`${resourceName}[class_room_id]`}
          />
        </>
      )}
      {hasPendingSuggestion && (
        <>
          <label className='fr-label' htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          <select
            className="fr-input"
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
          >
            {!selectedClassRoom && (
              <option key="class-room-null" selected disabled>
                -- Veuillez choisir une classe --
              </option>
            )}

            {classRoomsSuggestions.map(renderClassRoomOption)}
            <option value="">Autre classe</option>
          </select>
          
        </>
      )}
      {classRoomsSuggestions && classRoomsSuggestions.length === 0 && (
        <>
          <label className='fr-label' htmlFor={`${resourceName}_class_room_id`}>Classe (optionnel)</label>
          <input
            placeholder="Aucune classe disponible"
            readOnly
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
            value=""
            className={`fr-input ${classes || ''}`}
            type="text"
          />
        </>
      )}
    </div>
  );
}

export default RenderClassRoomsInput;
