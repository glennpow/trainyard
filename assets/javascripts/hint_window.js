function hint_window(name, url, width, height) {
  popped_window = window.open(url, name, 'height=' + height + ',width=' + width + ',toolbar=no,menubar=no,scrollbars=yes');
  return false;
}
