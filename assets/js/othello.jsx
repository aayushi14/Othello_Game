  import React from 'react';
  import ReactDOM from 'react-dom';
  import Board from './board.jsx';

  export default function game_init(root, channel) {
    let xNumbers: 2, oNumbers: 2, xWasNext: true;
    ReactDOM.render(<Othello channel={channel} />, root);
  }

  class Othello extends React.Component {
    constructor(props) {
      super(props);
      this.channel = props.channel;
      const initSquares = Array(64).fill(null);
      [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ['X', 'O', 'X', 'O'];

      this.state = {
        squares: initSquares,
        xNumbers: 2,
        oNumbers: 2,
        xWasNext: true,
        xIsNext: true,
        winner: null,
        availableMoves: [20, 29, 34, 43],
        availableMovesOpposite: [19, 26, 37, 44],
        status: null,
      };
      this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp) });
    }

    gotView(view) {
      this.setState(view.game);
    }

    calculateWinner(xNumbers, oNumbers) {
      return (xNumbers + oNumbers < 64) ? null : (xNumbers === oNumbers) ? 'XO' : (xNumbers > oNumbers ? 'X' : 'O');
    }

    flipSquares(squares, position, xIsNext) {
      let modifiedBoard = null;
      // Calculate row and col of the starting position
      let [startX, startY] = [position % 8, (position - position % 8) / 8];

      if (squares[position] !== null) {
        return null;
      }

      // Iterate all directions, these numbers are the offsets in the array to reach next square
      [1, 7, 8, 9, -1, -7, -8, -9].forEach((offset) => {
      let flippedSquares = modifiedBoard ? modifiedBoard.slice() : squares.slice();
      let atleastOneMarkIsFlipped = false;
      let [lastXpos, lastYPos] = [startX, startY];

        for (let y = position + offset; y < 64; y = y + offset) {

          // Calculate the row and col of the current square
          let [xPos, yPos] = [y % 8, (y - y % 8) / 8];

          // Fix when board is breaking into a new row or col
          if (Math.abs(lastXpos - xPos) > 1 || Math.abs(lastYPos - yPos) > 1) {
            break;
          }

          // Next square was occupied with the opposite color
          if (flippedSquares[y] === (!xIsNext ? 'X' : 'O')) {
            flippedSquares[y] = xIsNext ? 'X' : 'O';
            atleastOneMarkIsFlipped = true;
            [lastXpos, lastYPos] = [xPos, yPos];
            continue;
          }
          // Next square was occupied with the same color
          else if ((flippedSquares[y] === (xIsNext ? 'X' : 'O')) && atleastOneMarkIsFlipped) {
            flippedSquares[position] = xIsNext ? 'X' : 'O';
            modifiedBoard = flippedSquares.slice();
          }
          break;
        }
      });

      return modifiedBoard;
    }

    checkAvailableMoves(color, squares) {
      return squares
      .map((value, index) => { return this.flipSquares(squares, index, color) ? index : null; })
      .filter((item) => { return item !== null; });
    }

    handleClick(i) {
      //const history = this.state.history.slice(0, this.state.stepNumber + 1);
      //const current = history[this.state.stepNumber];

      if (this.calculateWinner(xNumbers, oNumbers) || squares[i]) {
        return;
      }

      const changedSquares = this.flipSquares(squares, i, this.state.xIsNext);

      if (changedSquares === null) {
        return;
      }

      const xNumbers = changedSquares.reduce((acc, current) => { return current === 'X' ? acc + 1 : acc }, 0);
      const oNumbers = changedSquares.reduce((acc, current) => { return current === 'O' ? acc + 1 : acc }, 0);

      let shouldTurnColor = this.checkAvailableMoves(!this.state.xIsNext, changedSquares).length > 0 ? !this.state.xIsNext : this.state.xIsNext

      this.setState({
        squares: changedSquares,
        xNumbers: xNumbers,
        oNumbers: oNumbers,
        xWasNext: shouldTurnColor,
        xIsNext: shouldTurnColor,
      });
    }

    resetGame() {
      this.channel.push("doReset")
      .receive("ok", this.gotView.bind(this));
    }

    local() {
      this.channel.push("doLocal")
      .receive("ok", this.gotView.bind(this));
    }

    render() {
      {this.local()}
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
            <div className="game-status">{this.state.status}&nbsp;{this.state.winner ? <button onClick={() => this.resetGame()}>Play again</button> : ''}</div>
          </div>
    		</div>
    	);
    }
}

/*
  resetState() {
    this.channel.push("doReset")
    .receive("ok", this.gotView.bind(this));
  }

  showTiles(id) {
    this.channel.push("showTile", {opentile: id})
    .receive("ok", this.gotView.bind(this));
  }

  differentTiles(queArray, opentile1, opentile2, disableClick) {
    this.channel.push("diffTiles", {queArray: queArray, opentile1:16, opentile2:16, disableClick: false})
    .receive("ok", this.gotView.bind(this));
  }

  componentDidUpdate() {
    let queArray = this.state.queArray;
    let opentile1 = this.state.opentile1;
    let opentile2 = this.state.opentile2;
    let disableClick = this.state.disableClick;

    if (opentile1 != 16 && opentile2 != 16 && queArray[opentile1] != queArray[opentile2]) {
      setTimeout(() => this.differentTiles(queArray, opentile1, opentile2, disableClick), 1000);
    }
  }

  render() {
    return (
      {this.state.queArray.map((letter, i) => <button className="tile"
      onClick={() => {this.showTiles(i)}} key={"letter" + i} id={i}
      disabled={this.state.disableClick}>
      <b>{letter}</b></button>)}
      <p>Number of Clicks: {this.state.totalClicks}</p>
      <p>Score: {this.state.score}/80</p>
      <button className="button" onClick={() => {this.resetState();}}>Reset Game</button>
      <button className="button" onClick={() => {this.resetState(); this.newGame();}}>New Game</button>
    );
  }
  }
*/
