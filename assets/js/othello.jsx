import React from 'react';
import ReactDOM from 'react-dom';
import Board from './board.jsx';

export default function game_init(root, channel) {
  ReactDOM.render(<Othello channel={channel} />, root);
}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    console.log(props);
    this.channel = props.channel;
    console.log(this.channel)
    const initSquares = Array(64).fill(null);
    [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ["X", "O", "X", "O"];
    console.log("constructor initSquares: ");
    console.log(initSquares);

    this.state = {
      squares: initSquares,
      xNumbers: 2,                              // number of black color pieces
      oNumbers: 2,                              // number of white color pieces
      xWasNext: true,
      xIsNext: true,
      availableMoves: [20, 29, 34, 43],         // the available moves for black player (current)
      availableMovesOpposite: [19, 26, 37, 44], // the available moves for white player
      black_player: "",                         // name of the player with black colored pieces
      white_player: "",                         // name of the player with white colored pieces
      spectators: [],                           // the list of spectators
      current_player: "",                       // black player moves first
    };

    // this.channel.on("tocheckAvailableMoves", this.checkAvailableMoves);
    // this.channel.on("tocheckAvailableMovesOpposite", this.checkAvailableMovesOpposite);

    this.channel.on("join", payload => {
      let game_state = payload.game_state;
      console.log("state after joining");
      console.log(game_state);
      this.setState(game_state);
    });

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });
  }

  gotView(view) {
    this.setState(view.game);
    console.log("gotView: ");
    console.log(view.game);
  }

  calculateWinner(xNumbers, oNumbers) {
    return (xNumbers + oNumbers < 64) ? null : (xNumbers === oNumbers) ? "XO" : (xNumbers > oNumbers ? "X" : "O");
  }

  handleClick(id) {
    console.log("Inside handleClick");
    this.channel.push("tohandleClick", {id: id})
    .receive("ok", this.gotView.bind(this));
  }


  resetGame() {
    this.channel.push("toReset")
    .receive("ok", this.gotView.bind(this));
  }

  checkAvailableMoves(xWasNext, squares) {
    this.channel.push("tocheckAvailableMoves", {xWasNext: xWasNext, squares: squares});
  }

  checkAvailableMovesOpposite(notxWasNext, squares) {
    this.channel.push("tocheckAvailableMovesOpposite", {notxWasNext: notxWasNext, squares: squares});
  }

  render() {
    console.log("INSIDE render: ");
    let winner = this.calculateWinner(this.state.xNumbers, this.state.oNumbers);
    console.log("winner: " + winner);
    this.checkAvailableMoves(this.state.xWasNext, this.state.squares);
    console.log("availableMoves: " + this.state.availableMoves);

    this.checkAvailableMovesOpposite(!this.state.xWasNext, this.state.squares);
    console.log("availableMovesOpposite: " + this.state.availableMovesOpposite);

    console.log("availableMoves length => " + this.state.availableMoves.length);

    if ((this.state.availableMoves.length === 0) && (this.state.availableMovesOpposite.length === 0)) {
      winner = this.state.xNumbers === this.state.oNumbers ? "XO" : this.state.xNumbers > this.state.oNumbers ? "X" : "O";
    }

    let status =
      	winner ?
      		(winner === "XO") ? 'It\'s a draw' : 'The winner is ' + (winner === 'W' ? 'White!' : 'Black!') :
      		[this.state.xIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', this.state.availableMoves.length, ' available moves.'].join('');



    let black_player_status = "";
    let white_player_status = "";
    if (this.state.black_player == "" || this.state.white_player == "") {
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
          <div className="row justify-content-md-center">
            <div className="col">

              <div className="container">
                <div className="row align-items-start">
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
                    </div>
                  </div>
                </div>
                <div><br /><br /><br /></div>
                <div className="row align-items-end">
                  <div className="col">
                    <div className="container">
                      <div className="row">
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
                </div>
              </div>
            </div>
            <div className="col-md-auto">
              <div className="container">
                <div className="game-left-side">
                  <div className="game-board">
                    <Board squares={this.state.squares} availableMoves={this.state.availableMoves} onClick={(i) => this.handleClick(i)} />
                  </div>
                  <div></div>
                </div>
              </div>
            </div>
            <div className="col">
              <div className="container">
                <div className="game-info">
                  <div>Black markers: {this.state.xNumbers}</div>
                  <div>White markers: {this.state.oNumbers}</div>
                  <br />
                  <div className="game-status">{status}&nbsp;{winner ? <button onClick={() => this.resetGame()}>Play again</button> : ''}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
