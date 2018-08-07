package helder.vdom;

class WrapperBase<RenderResult, Props: {}, State: {}> {
  var props: Props;
  var state: State;
  public function new() {}
  function onInit() {}
  function onCreate() {}
  function onUpdate() {}
  function onRemove() {}
  function doRender(): RenderResult return null;
}

interface View<RenderResult> {
  private function doRender(): RenderResult;
}

interface Lifecycle<Props: {}, State: {}> {
  private var props: Props;
  private var state: State;
  private function onInit(): Void;
  private function onCreate(): Void;
  //private function shouldUpdate(nextProps: Props, nextState: State): Bool;
  private function onUpdate(): Void;
  private function onRemove(): Void;
}