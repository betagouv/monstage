import PropTypes from 'prop-types';

const SectorPropType = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  external_url: PropTypes.string.isRequired,
});
export default SectorPropType;
