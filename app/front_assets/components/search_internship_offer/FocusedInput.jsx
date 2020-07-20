export default function focusedInput({check, focus}){
  if(focus ==null){
    return 'no-focus'
  }
  if(focus==check) {
    return 'focus-expanded'
  }
  return 'focus-collapsed'
}
