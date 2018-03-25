import React, {Component} from 'react';
import { Button } from 'reactstrap';

export default class Chat extends Component {
  constructor(props) {
    super(props);
  }

  componentDidUpdate(prevProps, prevState) {
    var element = document.getElementById('chatAppBody');
    element.scrollTop = element.scrollHeight - element.clientHeight;
  }

  render() {
    let msgs = this.props.msgs;
    let msgArea = [];
    for (let i = 0; i < msgs.length; i++) {
      let msg = msgs[i];
      let msgType = msg[0];
      let msgInfo = msg[1];
      let msgTypeClass = "";
      if (msgType == "system") {
        msgTypeClass = "systemMsg";
      } else if (msgType == "player") {
        msgTypeClass = "playerMsg";
      } else if (msgType == "spectator") {
        msgTypeClass = "spectatorMsg";
      }
      msgArea.push(<div className={ "row chatMsg " + msgTypeClass } key={"msg" + i}> { msgInfo } </div>);
    }

    return (
      <div id="chatApp" className="container game-container">
        <div id="chatAppHeader" className="row">ChatApp</div>
        <div id="chatAppBody" className="row">
          <div className="container game-container">{msgArea}</div>
        </div>
        <div className="row align-items-end">
          <div className="col">
            <input type="text" id="chatInput" onKeyUp={ (event) => event.keyCode === 13 && this.props.send_msg(event) } />
            <button id="post" onClick={ this.props.send_msg }>Send</button>
          </div>
        </div>
      </div>
    );
  }
}
