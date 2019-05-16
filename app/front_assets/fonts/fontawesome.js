import { library, dom, config } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'

// avoid SVG flickering
// see: https://github.com/FortAwesome/Font-Awesome/issues/11924
config.mutateApproach = 'sync'
library.add(fas, far)

// makes it works with Turbolink on document mutation
dom.watch({observeMutationsRoot: document})
