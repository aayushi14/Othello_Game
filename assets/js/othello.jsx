import React from 'react';
import ReactDOM from 'react-dom';
import Board from './board.jsx';
import Chat from './chat.jsx';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<Othello channel={channel} />, root);
}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.user_name = props.channel.params.user_name;

    const initSquares = Array(64).fill(null);
    [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ["X", "O", "X", "O"];

    this.state = {
      squares: initSquares,
      black_pieces: 2,                // number of black color pieces
      white_pieces: 2,                // number of white color pieces
      blackWasNext: true,             // black player's turn was next
      blackIsNext: true,              // black player's turn iss next
      availableMoves: [],             // the available moves for black player (current)
      availableMovesOpposite: [],     // the available moves for white player
      black_player: null,             // name of the player with black colored pieces
      white_player: null,             // name of the player with white colored pieces
      spectators: [],                 // the list of spectators
      current_player: null,           // black player moves first
      msgs: [],                       // list of messages
      status: "Waiting",              // status of the game
    };

    // join the channel
    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp)
    });

    // bind the functions to the instance
    this.send_msg = this.send_msg.bind(this);

    // listener for user join
    this.channel.on("join", payload => {
      this.setState(payload.game_state);
    });

    // listener for clicking on a square
    this.channel.on("handleClick", payload => {
      this.setState(payload.game_state);
    });

    // listener for game finish
    this.channel.on("finish", payload => {
      this.setState(payload.game_state);

      let black_pieces = this.state.black_pieces;
      let white_pieces = this.state.white_pieces;
      let black_player = this.state.black_player;
      let white_player = this.state.white_player;
      let game_over_msg = "";
      if (black_pieces == white_pieces) {
        game_over_msg = "Draw!"
      } else if (black_pieces > white_pieces) {
        game_over_msg = "Black player (" + black_player + ") wins!";
      } else {
        game_over_msg = "White player (" + white_player + ") wins!";
      }
      $("#gameOverMsg").html(game_over_msg);
      $("#gameOverModal").modal("show");
    });

    // listener for left game, in case that one of the player leaves in between
    this.channel.on("left_game", payload => {
      this.setState(payload.game_state);

      let black_player = this.state.black_player;
      let white_player = this.state.white_player;
      let game_over_msg = "";
      if (black_player == null) {
        game_over_msg = "The opponent escaped, " + white_player + " wins!"
      } else if (white_player == null) {
        game_over_msg = "The opponent escaped, " + black_player + " wins!"
      }
      $("#gameOverMsg").html(game_over_msg);
      $("#gameOverModal").modal("show");
    });

    this.channel.on("new_msg", payload => {
      this.setState(payload.game_state);
    });
  }

  gotView(view) {
    this.setState(view.game);
    console.log("gotView: ");
    console.log(view.game);
  }

  leaveGame() {
    this.channel.push("leaveGame")
    .receive("ok", this.gotView.bind(this));
  }

  handleClick(id) {
    console.log("Inside handleClick");
    console.log(this.state);
    this.channel.push("handleClick", {id: id});
  }

  checkAvailableMoves(blackWasNext, squares) {
    this.channel.push("tocheckAvailableMoves", {blackWasNext: blackWasNext, squares: squares})
     .receive("ok", this.gotView.bind(this));
  }

  // send message in the chat room
  send_msg(e) {
    let chatInput = document.querySelector("#chatInput");
    let msg = chatInput.value;
    this.channel.push("send_msg", { user_name: this.user_name, msg: msg });
    chatInput.value = "";
  }

  componentWillMount() {
    if(this.state.black_player == this.state.current_player ) {
    this.channel.push("tocheckAvailableMoves", {blackWasNext: this.state.blackWasNext, squares: this.state.squares})
    .receive("ok", this.gotView.bind(this));
    } else if (this.state.white_player == this.state.current_player ){
    this.channel.push("tocheckAvailableMoves", {blackWasNext: !this.state.blackWasNext, squares: this.state.squares})
    .receive("ok", this.gotView.bind(this));
    }
  }

  componentDidMount() {
    this.channel.on("handleClick", payload => {
      this.setState(payload.game_state);
    });
  }

  render() {

    if (this.state.availableMoves != []) {
      let status =
            [this.state.blackIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', this.state.availableMoves.length, ' available moves.'].join('');
    }

    let black_player_status = null;
    let white_player_status = null;
    if (this.state.black_player == null || this.state.white_player == null || this.state.status == "Waiting") {
      black_player_status = "Wait...";
      white_player_status = "Wait...";
    } else if (this.state.current_player == this.state.black_player) {
      black_player_status = "Make your Move";
      white_player_status = "Wait...";
    } else {
      black_player_status = "Wait...";
      white_player_status = "Make your Move";
    }

    return (
      <div className="game">
        <div className="container">
          <div className="row align-items-end">
            <div className="col">
              <nav className="navbar justify-content-end" role="navigation">
                <a href="/" className="pull-right ng-scope" onClick={() => this.leaveGame()}>Leave Game</a>
              </nav>
            </div>
          </div>
          <div className="row justify-content-md-center">

            <div className="col">
              <div className="container">
                <div className="row align-items-start">
                  <div className="col" id="black_side">BLACK</div>
                </div>
                <div className="row align-items-start">
                  <div className="col" id="notice">{ this.state.black_player }</div>
                </div>
                <div className="row align-items-start">
                  <div className="col" id="black_side">{ black_player_status }</div>
                </div>
                <div><br /><br /><br /></div>
                <div className="row align-items-end">
                  <div className="col" id="white_side">WHITE</div>
                </div>
                <div className="row">
                  <div className="col" id="message">{ this.state.white_player }</div>
                </div>
                <div className="row">
                  <div className="col" id="white_side">{ white_player_status }</div>
                </div>
              </div>
            </div>

            <div className="col-md-auto">
              <div className="container">
                <div className="game-left-side">
                  <div className="game-board">
                    <Board squares={this.state.squares} availableMoves={this.state.availableMoves} onClick={(i) => this.handleClick(i)} />
                  </div>
                </div>
              </div>
            </div>

            <div className="col align-items-start">
              <div className="container">
                <div className="row align-items-start">
                  <div className="col">
                    <div className="game-info">
                      <div>Black markers: {this.state.black_pieces}</div>
                      <div>White markers: {this.state.white_pieces}</div>
                      <br />
                      <div className="game-status">{status}</div>
                    </div>
                  </div>
                </div>
                <div><br /><br /><br /></div>
                <div className="row align-items-start">
                  <div className="col">
                    <Chat msgs={this.state.msgs} send_msg={this.send_msg} />
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    );
  }
}
