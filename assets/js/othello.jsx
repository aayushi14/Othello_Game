import React from 'react';
import ReactDOM from 'react-dom';
import Board from './board.jsx';

export default function game_init(root, channel) {
  ReactDOM.render(<Othello channel={channel} />, root);
}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    const initSquares = Array(64).fill(null);
    [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ["X", "O", "X", "O"];

    this.state = {
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true,
      availableMoves: [20, 29, 34, 43],
      availableMovesOpposite: [19, 26, 37, 44],
      player1: "",
      player2: "",
    };

    this.channel.on("tocheckAvailableMoves", this.checkAvailableMoves);
    this.channel.on("tocheckAvailableMovesOpposite", this.checkAvailableMovesOpposite);

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
    console.log(view.game.state);
    console.log(view.game.host);
  }

  calculateWinner(xNumbers, oNumbers) {
    return (xNumbers + oNumbers < 64) ? null : (xNumbers === oNumbers) ? "XO" : (xNumbers > oNumbers ? "X" : "O");
  }

  // flipSquares(squares, position, xIsNext) {
  //   let modifiedBoard = null;
  //   // Calculate row and col of the starting position
  //   let [startX, startY] = [position % 8, (position - position % 8) / 8];
  //   console.log("startX:" + startX + "startY:" + startY)
  //   if (squares[position] !== null) {
  //     return null;
  //   }
  //   console.log("Squares:" + squares);
  //   console.log("sp:" + squares[position]);
  //   // Iterate all directions, these numbers are the offsets in the array to reach next square
  //   [1, 7, 8, 9, -1, -7, -8, -9].forEach((offset) => {
  //   let flippedSquares = modifiedBoard ? modifiedBoard.slice() : squares.slice();
  //   console.log("flippedSquares:" + flippedSquares);
  //   let atleastOneMarkIsFlipped = false;
  //   let [lastXpos, lastYPos] = [startX, startY];
  //
  //     for (let y = position + offset; y < 64; y = y + offset) {
  //
  //       // Calculate the row and col of the current square
  //       let [xPos, yPos] = [y % 8, (y - y % 8) / 8];
  //       console.log("X:" + xPos + "Y:" + yPos);
  //       // Fix when board is breaking into a new row or col
  //       if (Math.abs(lastXpos - xPos) > 1 || Math.abs(lastYPos - yPos) > 1) {
  //         break;
  //       }
  //
  //       console.log("xIsNext: " + xIsNext);
  //       console.log("flippedSquares[y]: " + flippedSquares[y]);
  //       console.log("atleastOneMarkIsFlipped: " + atleastOneMarkIsFlipped);
  //       // Next square was occupied with the opposite color
  //       if (flippedSquares[y] === (!xIsNext ? 'X' : 'O')) {
  //         flippedSquares[y] = xIsNext ? 'X' : 'O';
  //         atleastOneMarkIsFlipped = true;
  //         [lastXpos, lastYPos] = [xPos, yPos];
  //         continue;
  //       }
  //       // Next square was occupied with the same color
  //       else if ((flippedSquares[y] === (xIsNext ? 'X' : 'O')) && atleastOneMarkIsFlipped) {
  //         flippedSquares[position] = xIsNext ? 'X' : 'O';
  //         modifiedBoard = flippedSquares.slice();
  //       }
  //       break;
  //     }
  //   });
  //
  //   console.log("modifiedBoard: " + modifiedBoard);
  //   return modifiedBoard;
  // }

  // checkAvailableMoves(color, squares) {
  //   return this.state.squares
  //   .map((value, index) => { return this.flipSquares(squares, index, color) ? index : null; })
  //   .filter((item) => { return item !== null; });
  // }

  // handleClick(i) {
  //   if (this.calculateWinner(this.state.xNumbers, this.state.oNumbers) || this.state.squares[i]) {
  //     return;
  //   }
  //
  //   const changedSquares = this.flipSquares(this.state.squares, i, this.state.xIsNext);
  //
  //   if (changedSquares === null) {
  //     return;
  //   }
  //
  //   const xNumbers = changedSquares.reduce((acc, current) => { return current === 'X' ? acc + 1 : acc }, 0);
  //   const oNumbers = changedSquares.reduce((acc, current) => { return current === 'O' ? acc + 1 : acc }, 0);
  //
  //   let shouldTurnColor = this.checkAvailableMoves(!this.state.xIsNext, changedSquares).length > 0 ? !this.state.xIsNext : this.state.xIsNext
  //
  //   this.setState({
  //     squares: changedSquares,
  //     xNumbers: xNumbers,
  //     oNumbers: oNumbers,
  //     xWasNext: shouldTurnColor,
  //     xIsNext: shouldTurnColor,
  //     player1: "rc",
  //     player2: ""
  //   });
  // }

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
    this.channel.push("tocheckAvailableMoves", {xWasNext: xWasNext, squares: squares})
    .receive("ok", this.gotView.bind(this));
  }

  checkAvailableMovesOpposite(notxWasNext, squares) {
    this.channel.push("tocheckAvailableMovesOpposite", {notxWasNext: notxWasNext, squares: squares})
    .receive("ok", this.gotView.bind(this));
  }

  render() {
    let winner = this.calculateWinner(this.state.xNumbers, this.state.oNumbers);
    console.log("winner: " + winner);

    // this.checkAvailableMoves(this.state.xWasNext, this.state.squares);
    // console.log("availableMoves: " + this.state.availableMoves);

    // this.checkAvailableMovesOpposite(!this.state.xWasNext, this.state.squares);
    // console.log("availableMovesOpposite: " + this.state.availableMovesOpposite);

    console.log("availableMoves.length: " + this.state.availableMoves.length);
    if ((this.state.availableMoves.length === 0) && (this.state.availableMovesOpposite.length === 0)) {
      winner = this.state.xNumbers === this.state.oNumbers ? "XO" : this.state.xNumbers > this.state.oNumbers ? "X" : "O";
    }

    let status =
      	winner ?
      		(winner === "XO") ? 'It\'s a draw' : 'The winner is ' + (winner === 'W' ? 'White!' : 'Black!') :
      		[this.state.xIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', this.state.availableMoves.length, ' available moves.'].join('');
    console.log(this.state);
    return (
      <div className="game">
        <div className="game-left-side">
          <div className="game-board">
            <Board squares={this.state.squares} availableMoves={this.state.availableMoves} onClick={(i) => this.handleClick(i)} />
          </div>
          <div></div>
        </div>
        <div className="game-info">
          <div>Black markers: {this.state.xNumbers}</div>
          <div>White markers: {this.state.oNumbers}</div>
          <br />
          <div className="game-status">{status}&nbsp;{winner ? <button onClick={() => this.resetGame()}>Play again</button> : ''}</div>
        </div>
      </div>
    );
  }
}
