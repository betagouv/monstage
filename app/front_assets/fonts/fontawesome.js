import { library, dom, config } from '@fortawesome/fontawesome-svg-core'
// get list with ./infra/dev/find-font-awesome-icons.sh
// grep -riE 'fas' ./app   | grep -E 'fa(-[a-z]+)+' --only-matching | sort | uniq
import { faAngleLeft,
         faArrowCircleRight,
         faArrowCircleUp,
         faBan,
         faCheck,
         faCheckCircle,
         faChevronDown,
         faChevronLeft,
         faChevronRight,
         faExclamationTriangle,
         faExternalLinkAlt,
         faFileAlt,
         faFilePdf,
         faHourglassStart,
         faLayerGroup,
         faMapMarker,
         faMapMarkerAlt,
         faPen,
         faPlus,
         faQuestionCircle,
         faSignature,
         faSmile,
         faTimes,
         faTrash } from '@fortawesome/free-solid-svg-icons'

// get list with ./infra/dev/find-font-awesome-icons.sh
// grep -riE 'far' ./app   | grep -E 'fa(-[a-z]+)+' --only-matching | sort | uniq
import { faCircle } from '@fortawesome/free-regular-svg-icons'

// avoid SVG flickering
// see: https://github.com/FortAwesome/Font-Awesome/issues/11924
config.mutateApproach = 'sync'
library.add(faAngleLeft,
            faArrowCircleRight,
            faArrowCircleUp,
            faBan,
            faCheck,
            faCheckCircle,
            faChevronDown,
            faChevronLeft,
            faChevronRight,
            faExclamationTriangle,
            faExternalLinkAlt,
            faFileAlt,
            faFilePdf,
            faHourglassStart,
            faLayerGroup,
            faMapMarker,
            faMapMarkerAlt,
            faPen,
            faPlus,
            faQuestionCircle,
            faSignature,
            faSmile,
            faTimes,
            faTrash,
            faCircle);

// makes it works with Turbolink on document mutation
dom.watch({observeMutationsRoot: document})
