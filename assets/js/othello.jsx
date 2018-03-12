  import React from 'react';
  import ReactDOM from 'react-dom';
  import Board from './board.jsx';

  export default function game_init(root, channel) {
    // let xNumbers: 2, oNumbers: 2, xWasNext: true;
    ReactDOM.render(<Othello channel={channel} />, root);
  }

  class Othello extends React.Component {
    constructor(props) {
      super(props);
      this.channel = props.channel;
      
      const initSquares = Array(64).fill(null);
      [initSquares[8 * 3 + 3], initSquares[8 * 3 + 4], initSquares[8 * 4 + 4], initSquares[8 * 4 + 3]] = ['X', 'O', 'X', 'O'];

      this.state = {
        history: [{
          squares: initSquares,
          xNumbers: 2,
          oNumbers: 2,
          xWasNext: true }],
          stepNumber: 0,
          xIsNext: true
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
        const history = this.state.history.slice(0, this.state.stepNumber + 1);
        const current = history[this.state.stepNumber];
        console.log(history);
        if (this.calculateWinner(current.xNumbers, current.oNumbers) || current.squares[i]) {
          return;
        }

        const changedSquares = this.flipSquares(current.squares, i, this.state.xIsNext);

        if (changedSquares === null) {
          return;
        }

        const xNumbers = changedSquares.reduce((acc, current) => { return current === 'X' ? acc + 1 : acc }, 0);
        const oNumbers = changedSquares.reduce((acc, current) => { return current === 'O' ? acc + 1 : acc }, 0);

        let shouldTurnColor = this.checkAvailableMoves(!this.state.xIsNext, changedSquares).length > 0 ? !this.state.xIsNext : this.state.xIsNext

        this.setState({
          history: history.concat([{
            squares: changedSquares,
            xNumbers: xNumbers,
            oNumbers: oNumbers,
            xWasNext: shouldTurnColor
          }]),
          stepNumber: history.length,
          xIsNext: shouldTurnColor,
        });
      }

      jumpTo(step) {
        this.setState({
          stepNumber: parseInt(step, 0),
          xIsNext: this.state.history[step].xWasNext
        });
      }

      resetGame() {
        this.jumpTo(0);
        this.setState({
          history: this.state.history.slice(0, 1)
        })
      }

      resetGame() {
        this.channel.push("doReset")
        .receive("ok", this.gotView.bind(this));
      }

      render() {
      		const history = this.state.history.slice();
      		const current = history[this.state.stepNumber];
          console.log(current);
          console.log(history);
      		let winner = this.calculateWinner(current.xNumbers, current.oNumbers);

      		const moves = history.map((step, move) => {
      			const desc = move ? 'Go to move #' + move : 'Go to game start';
      			return (
      				<option key={move} value={move}>
      					{desc}
      				</option>
      			);
      		});

      		const selectMoves = () => {
      			return (
      				<select className="select" id="dropdown" ref={(input) => this.selectedMove = input} onChange={() => this.jumpTo(this.selectedMove.value)} value={this.state.stepNumber}>
      					{moves}
      				</select>
      			)
      		}

      		let availableMoves = this.checkAvailableMoves(current.xWasNext, current.squares);
      		let availableMovesOpposite = this.checkAvailableMoves(!current.xWasNext, current.squares);

      		if ((availableMoves.length === 0) && (availableMovesOpposite.length === 0)) {
      			winner = current.xNumbers === current.oNumbers ? 'XO' : current.xNumbers > current.oNumbers ? 'X' : 'O';
      		}

      		let status =
      			winner ?
      				(winner === 'XO') ? 'It\'s a draw' : 'The winner is ' + (winner === 'W' ? 'White!' : 'Black!') :
      				[this.state.xIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', availableMoves.length, ' available moves.'].join('');

      		return (
      			<div className="game">
              <div className="game-left-side">
                <div className="game-board">
            			<Board squares={current.squares} availableMoves={availableMoves} onClick={(i) => this.handleClick(i)} />
            		</div>
            		<div></div>
              </div>
              <div className="game-info">
                <div>Black markers: {current.xNumbers}</div>
          			<div>White markers: {current.oNumbers}</div>
          			<br />
          			<div>Select a previous move:</div>
          			<div>{selectMoves()}</div>
          			<br />
                <div className="game-status">{status}&nbsp;{winner ? <button onClick={() => this.resetGame()}>Play again</button> : ''}</div>
              </div>
      			</div>
      		);
      }
  }
