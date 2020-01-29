resource:
  type="string"
  indexed="true"
  stored="true"
  multiValued="true"

resource_context_field:
  type="string"
  indexed="true"
  stored="true"
  multiValued="false"

txt:
  type="text"
  stored="true"
  termVectors="true"
  multiValued="false"
  indexed="true"

suggest_txt:
  type="suggest"
  indexed="true"
  stored="true"
  multiValued="true"

<copyField source="txt"  dest="autocomplete" />
autocomplete:
  type="textSpell"
  indexed="true"
  stored="false"
  multiValued="false"
