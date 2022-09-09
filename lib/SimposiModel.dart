class SimposiModel{
  static final SimposiModel shared = SimposiModel._constructor();


  SimposiModel._constructor(){
    initModel();
  }

  void initModel() async {
    print("I am alive");
  }




}