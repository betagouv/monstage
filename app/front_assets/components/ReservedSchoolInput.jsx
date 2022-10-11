import React from 'react';
import PropTypes from 'prop-types';
import SearchSchool from './SearchSchool';
import SchoolPropType from '../prop_types/school';

class ReservedSchoolInput extends React.Component {
  static propTypes = {
    classes: PropTypes.string,
    label: PropTypes.string.isRequired,
    required: PropTypes.bool.isRequired,
    resourceName: PropTypes.string.isRequired,
    selectClassRoom: PropTypes.bool.isRequired,
    existingSchool: PropTypes.objectOf(SchoolPropType),
    existingClassRoom: PropTypes.objectOf(PropTypes.object),
  };

  static defaultProps = {
    classes: null,
    existingSchool: null,
    existingClassRoom: null,
  };

  state = {
    checked: null,
  };

  componentDidMount() {
    this.setState({ checked: !!this.props.existingSchool });
  }

  toggleChange = (_event) => {
    const { checked } = this.state;
    this.setState({ checked: !checked });
  };

  render() {
    const { existingSchool, resourceName } = this.props;
    const { checked } = this.state;
    const checkedOrHasExistingSchool = (checked === true) || (checked === null && existingSchool);
    return (
      <>
        <div className="fr-checkbox-group fr-checkbox-group--sm test-school-reserved" onClick={this.toggleChange}>
          <input
            type="checkbox"
            name="is_reserved"
            value="true"
            aria-labelledby="is_reserved_label"
            checked={checkedOrHasExistingSchool}
          />
          <label htmlFor="is_reserved" id="is_reserved_label">
            <span className="ml-1 font-weight-normal">
              Ce stage est réservé à un seul établissement ?
            </span>
            <small className="form-text text-muted">
              Les stages reservés ne seront proposés qu'aux élèves de l'établissement selectionné.
            </small>
          </label>
        </div>
        {checkedOrHasExistingSchool ? <SearchSchool {...this.props} />
                                    : <input type="hidden" value="" name={`${resourceName}[school_id]`} />
        }
      </>
    );
  }
}
export default ReservedSchoolInput;
